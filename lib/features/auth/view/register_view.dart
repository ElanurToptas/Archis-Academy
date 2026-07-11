import 'package:archis_academy/core/navigation/app_router.dart';
import 'package:archis_academy/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SvgPicture.asset('assets/images/logo.svg', height: 50),
                const SizedBox(height: 24),
                const Text(
                  "Hesap oluştur",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 30),

                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        label: "Ad",
                        hint: "Adını gir",
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        label: "Soyad",
                        hint: "Soyadını gir",
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        label: "E-posta",
                        hint: "E-postanı gir",
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        label: "Şifre",
                        hint: "Şifreni gir",
                        obscure: true,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        label: "Şifreyi onayla",
                        hint: "Şifreni tekrar gir",
                        obscure: true,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity, 
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, 
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                     
                    },
                    child: const Text(
                      "Kayıt ol",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Zaten bir hesabın mı var? "),
                    GestureDetector(
                      onTap: () {
                        context.go(AppRoutes.login);
                      },
                      child: const Text(
                        "Giriş yap",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
