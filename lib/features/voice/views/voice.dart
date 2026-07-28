import 'dart:async';
import 'package:archis_academy/features/voice/model/voice_model.dart';
import 'package:archis_academy/features/voice/service/voice_service.dart';
import 'package:archis_academy/product/init/language/locale_keys.g.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  late final AudioRecorder _audioRecorder;
  late final AudioPlayer _audioPlayer;
  final VoiceService _voiceService = VoiceService();

  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  bool _isRecording = false;
  bool _isUploading = false;
  DateTime? _recordingStartedAt;
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;

  String? _playingVoiceId;
  late final Stream<List<VoiceModel>> _voicesStream;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    _voicesStream = _voiceService.getVoices(_currentUserId);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        setState(() {
          _playingVoiceId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    if (_isRecording) {
    _audioRecorder.stop();
  }
    _audioRecorder.dispose();
    _audioPlayer.dispose();
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

  Future<void> _sesiToggleEt(VoiceModel voice) async {
    try {
      if (_playingVoiceId == voice.id) {
        await _audioPlayer.stop();
        setState(() {
          _playingVoiceId = null;
        });
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(voice.downloadUrl));
        setState(() {
          _playingVoiceId = voice.id;
        });
      }
    } catch (e) {
      debugPrint('Ses oynatma hatası: $e');
      _showError(LocaleKeys.voice_playbackFailed.tr());
    }
  }

  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    String two(int n) => n.toString().padLeft(2, '0');
    final minutes = two(d.inMinutes.remainder(60));
    final secondsStr = two(d.inSeconds.remainder(60));
    return '$minutes:$secondsStr';
  }

    String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return isToday
        ? LocaleKeys.voice_today.tr(args: [time])
        : LocaleKeys.voice_dateTime.tr(args: ['${dt.day}.${dt.month}.${dt.year}', time]);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleKeys.voice_title.tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<VoiceModel>>(
                stream: _voicesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        LocaleKeys.voice_loadErrorWithDetails.tr(
                          args: ['${snapshot.error}'],
                        ),
                      ),
                    );
                  }
  final recordings = snapshot.data ?? [];

                  if (recordings.isEmpty) {
                    return Center(
                      child: Text(
                        LocaleKeys.voice_emptyState.tr(),
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: recordings.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = recordings[index];
                      final isPlaying = _playingVoiceId == item.id;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: const Color.fromARGB(255, 245, 232, 245),
                          child: Icon(Icons.mic, color: const Color.fromARGB(255, 142, 56, 139)),
                        ),
                        title: Text(
                          LocaleKeys.voice_recordLabel.tr(
                            args: [_formatDuration(item.durationSeconds)],
                          ),
                        ),
                        subtitle: Text(_formatTimestamp(item.timestamp)),
                        trailing: IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            size: 36,
                            color: const Color.fromARGB(255, 142, 56, 139),
                          ),
                          onPressed: () => _sesiToggleEt(item),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                children: [
                  if (_isUploading) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LocaleKeys.voice_uploading.tr(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    Text(
                      _isRecording
                          ? LocaleKeys.voice_recordingStatus.tr(
                              args: [_formatDuration(_elapsed.inSeconds)],
                            )
                          : LocaleKeys.voice_waitingStatus.tr(),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 142, 56, 139),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
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
                          backgroundColor: const Color.fromARGB(255, 230, 200, 227),
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
                          backgroundColor: Colors.red[100],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
