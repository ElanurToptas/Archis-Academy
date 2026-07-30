import 'package:archis_academy/core/navigation/app_router.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(child: Center(
        child: Text("Voice"),
      ))
    );
  }
}

