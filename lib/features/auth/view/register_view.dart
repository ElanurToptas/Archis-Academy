import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      body:SafeArea(child: 
       Center(
         child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            SvgPicture.asset('assets/images/logo.svg',
            height: 50),
            const SizedBox(height: 24),
            const Text(
                  "Hesap oluştur",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 30),
          ],),
         ),
       ))
    );
  }
}