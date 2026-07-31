import 'dart:async';
import 'dart:io';
import 'package:archis_academy/core/navigation/app_router.dart';
import 'package:archis_academy/features/home/service/voice_service.dart';
import 'package:archis_academy/features/auth/repository/auth_repository.dart';
import 'package:archis_academy/features/home/widgets/recording_icon.dart';
import 'package:archis_academy/features/home/widgets/waveform_painter.dart';
import 'package:archis_academy/product/init/language/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final AudioRecorder _audioRecorder;
  final VoiceService _voiceService = VoiceService();

  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  bool _isRecording = false;
  bool _isUploading = false;
  bool _isProcessing = false;
  DateTime? _recordingStartedAt;
  Timer? _elapsedTimer;
  final ValueNotifier<Duration> _elapsedNotifier = ValueNotifier(Duration.zero);

  static const int _barCount = 40;
  static const int _maxRecordingSeconds = 120;

  StreamSubscription<Amplitude>? _amplitudeSub;

  final ValueNotifier<List<double>> _amplitudesNotifier = ValueNotifier(
    List.filled(_barCount, 0.0, growable: true),
  );

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _amplitudeSub?.cancel();
    _elapsedNotifier.dispose();
    _amplitudesNotifier.dispose();
    if (_isRecording) {
      _audioRecorder.stop();
    }
    _audioRecorder.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _ensureMicrophonePermission() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (!mounted) return false;
      final goToSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(LocaleKeys.voice_micPermissionRequiredTitle.tr()),
          content: Text(LocaleKeys.voice_micPermissionRequiredMessage.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(LocaleKeys.voice_cancel.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(LocaleKeys.voice_openSettings.tr()),
            ),
          ],
        ),
      );
      if (goToSettings == true) {
        await openAppSettings();
      }
      return false;
    }

    final requested = await Permission.microphone.request();
    return requested.isGranted;
  }

  double _normalizeAmplitude(double db) {
    const minDb = -45.0;
    const maxDb = 0.0;
    final clamped = db.clamp(minDb, maxDb);
    return (clamped - minDb) / (maxDb - minDb);
  }

  Future<void> _kaydiBaslat() async {
    _isProcessing = true;
    try {
      final hasPermission = await _ensureMicrophonePermission();
      if (!hasPermission) {
        _showError(LocaleKeys.voice_permissionDenied.tr());
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/record_${DateTime.now().millisecondsSinceEpoch}.m4a';

      const config = RecordConfig(encoder: AudioEncoder.aacLc);

      await _audioRecorder.start(config, path: path);
      if (!mounted) {
        await _audioRecorder.stop();
        return;
      }

      _recordingStartedAt = DateTime.now();
      _elapsedNotifier.value = Duration.zero;
      _amplitudesNotifier.value = List.filled(_barCount, 0.0, growable: true);

      _elapsedTimer?.cancel();

      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final newElapsed = DateTime.now().difference(_recordingStartedAt!);
        _elapsedNotifier.value = newElapsed;

        if (newElapsed.inSeconds >= _maxRecordingSeconds && !_isProcessing) {
          _showError(LocaleKeys.voice_timeUp.tr());
          _kaydiDurdur();
        }
      });

      _amplitudeSub?.cancel();
      _amplitudeSub = _audioRecorder
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .listen((amp) {
                  debugPrint('amp.current: ${amp.current}');
            if (!mounted) return;
            final updated = List<double>.from(_amplitudesNotifier.value)
              ..removeAt(0)
              ..add(_normalizeAmplitude(amp.current));
            _amplitudesNotifier.value = updated;
          });

      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      debugPrint('Kayıt başlatılırken hata oluştu: $e');
      _showError(LocaleKeys.voice_startFailed.tr());
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _kaydiDurdur() async {
    _isProcessing = true;
    try {
      final path = await _audioRecorder.stop();
      _elapsedTimer?.cancel();
      _amplitudeSub?.cancel();

      if (!mounted) return;

      if (path != null && _recordingStartedAt != null) {
        final duration = DateTime.now().difference(_recordingStartedAt!);

        setState(() {
          _isRecording = false;
          _isUploading = true;
        });

        await _voiceService.uploadAndSaveVoice(
          filePath: path,
          userId: _currentUserId,
          durationSeconds: duration.inSeconds,
        );

        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }

        if (!mounted) return;
        setState(() {
          _isUploading = false;
        });
      } else {
        setState(() {
          _isRecording = false;
        });
        _showError(LocaleKeys.voice_saveFailed.tr());
      }
    } catch (e) {
      debugPrint('Kayıt durdurulamadı veya yüklenemedi: $e');
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _isRecording = false;
      });
      _showError(LocaleKeys.voice_uploadFailed.tr());
    } finally {
      _isProcessing = false;
    }
  }

  void _onTap() {
    if (_isProcessing || _isUploading) return;
    if (_isRecording) {
      _kaydiDurdur();
    } else {
      _kaydiBaslat();
    }
  }

  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    String two(int n) => n.toString().padLeft(2, '0');
    final minutes = two(d.inMinutes.remainder(60));
    final secondsStr = two(d.inSeconds.remainder(60));
    return '$minutes:$secondsStr';
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _logout,
            child: Text(
              LocaleKeys.voice_logout.tr(),
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onTap: _onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isUploading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    LocaleKeys.voice_uploading.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  ValueListenableBuilder<List<double>>(
                    valueListenable: _amplitudesNotifier,
                    builder: (context, amplitudes, child) {
                      return SizedBox(
                        height: 220,
                        width: 220,
                        child: CustomPaint(
                          painter: WaveformPainter(
                            amplitudes: amplitudes,
                            color: _isRecording
                                ? Colors.red
                                : colorScheme.primary,
                            isRecording: _isRecording,
                          ),
                         child: RecordingIcon(isRecording: _isRecording),
                        ),
                      );
                    },
                  ),
                  
                  ValueListenableBuilder<Duration>(
                    valueListenable: _elapsedNotifier,
                    builder: (context, elapsed, _) {
                      return Text(
                        _isRecording
                            ? _formatDuration(elapsed.inSeconds)
                            : "",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
