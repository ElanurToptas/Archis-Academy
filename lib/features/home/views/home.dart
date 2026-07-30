import 'dart:async';
import 'package:archis_academy/core/navigation/app_router.dart';
import 'package:archis_academy/features/home/model/voice_model.dart';
import 'package:archis_academy/features/home/service/voice_service.dart';
import 'package:archis_academy/features/auth/repository/auth_repository.dart';
import 'package:archis_academy/product/init/language/locale_keys.g.dart';
import 'package:archis_academy/product/init/theme/app_theme.dart';
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
  DateTime? _recordingStartedAt;
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
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

  Future<void> _kaydiBaslat() async {
    try {
      final hasPermission = await _ensureMicrophonePermission();
      if (!hasPermission) {
        _showError(LocaleKeys.voice_permissionDenied.tr());
        return;
      }

      // Kayıtları kalıcı olarak saklamak için uygulama belgeler dizinini
      // kullanıyoruz — geçici dizin (temp) sistem tarafından silinebilir.
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/record_${DateTime.now().millisecondsSinceEpoch}.m4a';

      const config = RecordConfig(encoder: AudioEncoder.aacLc);
      await _audioRecorder.start(config, path: path);

      if (!mounted) return;

      _recordingStartedAt = DateTime.now();
      _elapsed = Duration.zero;
      _elapsedTimer?.cancel();
      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          _elapsed = DateTime.now().difference(_recordingStartedAt!);
        });
      });

      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      debugPrint('Kayıt başlatılırken hata oluştu: $e');
      _showError(LocaleKeys.voice_startFailed.tr());
    }
  }

  Future<void> _kaydiDurdur() async {
    try {
      final path = await _audioRecorder.stop();
      _elapsedTimer?.cancel();

      if (!mounted) return;

      if (path != null && _recordingStartedAt != null) {
        final duration = DateTime.now().difference(_recordingStartedAt!);

        setState(() {
          _isRecording = false;
          _isUploading = true; // Yükleniyor durumunu açıyoruz
        });

        // 1. Firebase Storage ve Firestore'a Gönderim
        await _voiceService.uploadAndSaveVoice(
          filePath: path,
          userId: _currentUserId,
          durationSeconds: duration.inSeconds,
        );

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
      setState(() {
        _isUploading = false;
        _isRecording = false;
      });
      _showError(LocaleKeys.voice_uploadFailed.tr());
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(LocaleKeys.voice_title.tr()),
        actions: [
          TextButton(
            onPressed: _logout,
            child: Text(
              "Çıkış",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isUploading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                LocaleKeys.voice_uploading.tr(),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
            ] else ...[
              Icon(
                Icons.mic,
                size: 64,
                color: _isRecording
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                _isRecording
                    ? _formatDuration(_elapsed.inSeconds)
                    : LocaleKeys.voice_waitingStatus.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: (_isRecording || _isUploading)
                      ? null
                      : _kaydiBaslat,
                  icon: const Icon(Icons.mic),
                  label: Text(LocaleKeys.voice_startButton.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.startButtonBg,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: (!_isRecording || _isUploading)
                      ? null
                      : _kaydiDurdur,
                  icon: const Icon(Icons.stop),
                  label: Text(LocaleKeys.voice_stopButton.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.errorContainer,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
