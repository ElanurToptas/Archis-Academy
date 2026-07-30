import 'package:archis_academy/features/home/model/voice_model.dart';
import 'package:archis_academy/features/home/service/voice_service.dart';
import 'package:archis_academy/product/init/language/locale_keys.g.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late final AudioPlayer _audioPlayer;
  final VoiceService _voiceService = VoiceService();
  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  String? _playingVoiceId;
  late final Stream<List<VoiceModel>> _voicesStream;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _voicesStream = _voiceService.getVoices(_currentUserId);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        if (!mounted) return;
        setState(() {
          _playingVoiceId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  String _replaceLocalizationArgs(String text, List<Object> args) {
    var result = text;
    for (final arg in args) {
      result = result.replaceFirst('%s', arg.toString());
    }
    return result;
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
    final date = '${dt.day}.${dt.month}.${dt.year}';
    return isToday
        ? _replaceLocalizationArgs(LocaleKeys.voice_today.tr(), [time])
        : _replaceLocalizationArgs(LocaleKeys.voice_dateTime.tr(), [
            date,
            time,
          ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Text("Kayıtlarım"),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<VoiceModel>>(
          stream: _voicesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
        
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  _replaceLocalizationArgs(
                    LocaleKeys.voice_loadErrorWithDetails.tr(),
                    ['${snapshot.error}'],
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
                    backgroundColor: const Color.fromARGB(
                      255,
                      245,
                      232,
                      245,
                    ),
                    child: Icon(
                      Icons.mic,
                      color: const Color.fromARGB(255, 142, 56, 139),
                    ),
                  ),
                  title: Text(
                    _replaceLocalizationArgs(
                      LocaleKeys.voice_recordLabel.tr(),
                      [_formatDuration(item.durationSeconds)],
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
    );
  }
}
