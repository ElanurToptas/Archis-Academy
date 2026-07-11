import 'package:archis_academy/core/navigation/app_router.dart';
import 'package:archis_academy/features/auth/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthRepository())),
      ],
      child: const MyApp(),
    ),);
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Archis Academy',
      routerConfig: router,
    );
  }
}