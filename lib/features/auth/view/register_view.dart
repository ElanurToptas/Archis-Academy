import 'package:archis_academy/core/navigation/app_router.dart';
import 'package:archis_academy/features/auth/widgets/custom_text_field.dart';
import 'package:archis_academy/features/auth/repository/auth_repository.dart';
import 'package:archis_academy/product/init/language/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

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
                Text(
                  LocaleKeys.auth_register_title.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),

                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        label: LocaleKeys.auth_register_nameLabel.tr(),
                        hint: LocaleKeys.auth_register_nameHint.tr(),
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        label: LocaleKeys.auth_register_surnameLabel.tr(),
                        hint: LocaleKeys.auth_register_surnameHint.tr(),
                        controller: surnameController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        label: LocaleKeys.auth_register_emailLabel.tr(),
                        hint: LocaleKeys.auth_register_emailHint.tr(),
                        controller: emailController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        label: LocaleKeys.auth_register_passwordLabel.tr(),
                        hint: LocaleKeys.auth_register_passwordHint.tr(),
                        controller: passwordController,
                        obscure: true,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),
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
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          surnameController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              LocaleKeys.auth_register_emptyFields.tr(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (passwordController.text.length < 3) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              LocaleKeys.auth_register_passwordTooShort.tr(),
                            ),
                          ),
                        );
                        return;
                      }

                      if (!isValidEmail(emailController.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              LocaleKeys.auth_register_invalidEmail.tr(),
                            ),
                          ),
                        );
                        return;
                      }

                      final authProvider = context.read<AuthProvider>();
                      // 1. İşlemin sonucunu bir değişkene alın
                      final success = await authProvider.signUp(
                        nameController.text,
                        surnameController.text,
                        emailController.text,
                        passwordController.text,
                      );
                      debugPrint("Kayıt sonucu: $success");
                      if (!mounted) return;

                      if (success) {
                        debugPrint("Başarılı, ana sayfaya gidiliyor.");
                        context.go(AppRoutes.home);
                      } else {
                        debugPrint("Başarısız, hata mesajı gösteriliyor.");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              LocaleKeys.auth_register_registerFailed.tr(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },

                    child: Text(
                      LocaleKeys.auth_register_submit.tr(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(LocaleKeys.auth_register_alreadyHaveAccount.tr()),
                    GestureDetector(
                      onTap: () {
                        context.go(AppRoutes.login);
                      },
                      child: Text(
                        LocaleKeys.auth_register_login.tr(),
                        style: const TextStyle(
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
