import 'package:archis_academy/core/navigation/app_router.dart';
import 'package:archis_academy/features/auth/widgets/custom_text_field.dart';
import 'package:archis_academy/features/auth/repository/auth_repository.dart';
import 'package:archis_academy/product/init/language/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
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
                  LocaleKeys.auth_login_title.tr(),
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
                        label: LocaleKeys.auth_login_nameLabel.tr(),
                        hint: LocaleKeys.auth_login_nameHint.tr(),
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        label: LocaleKeys.auth_login_passwordLabel.tr(),
                        hint: LocaleKeys.auth_login_passwordHint.tr(),
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
                          passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              LocaleKeys.auth_login_emptyFields.tr(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      try {
                        final bool isSuccess = await context
                            .read<AuthProvider>()
                            .signIn(
                              nameController.text,
                              passwordController.text,
                            );

                        if (!mounted) return;

                        if (isSuccess) {
                          context.go(AppRoutes.home);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Geçersiz kullanıcı adı veya şifre!",
                              ), 
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${e.toString().replaceAll("Exception: ", "")}",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },

                    child: Text(
                      LocaleKeys.auth_login_title.tr(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(LocaleKeys.auth_login_alreadyHaveAccount.tr()),
                    GestureDetector(
                      onTap: () {
                        context.go(AppRoutes.register);
                      },
                      child: Text(
                        LocaleKeys.auth_login_register.tr(),
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
