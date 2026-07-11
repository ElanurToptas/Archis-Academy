import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoApp extends StatefulWidget {
  const VideoApp({super.key});

  @override
  State<VideoApp> createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/videos/video.mp4'); 
    // It is used to upload and check the video.
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {}); 
    }).catchError((error) {
      print("Video yükleme hatası: $error"); 
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The circle will show the video until it loads; once it's loaded, it will show the video.
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
           // tracks video clicks
            onTap: () {
              setState(() {
                _controller.value.isPlaying 
                    ? _controller.pause() 
                    : _controller.play();
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  // The video size remains unchanged.
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
        
                if (!_controller.value.isPlaying)
                  const Icon(Icons.play_circle_fill, size: 60, color: Colors.white70),
              ],
            ),
          );
        } else {
          // It spins on the screen until the data arrives.
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}