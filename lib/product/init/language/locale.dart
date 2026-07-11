import 'package:flutter/material.dart';

@immutable
final class AppConstants {
  const AppConstants._();
  
  static const LANG_PATH = 'assets/translations';
  static const EN_LOCALE = Locale('en', 'US');
  static const TR_LOCALE = Locale('tr', 'TR');
  
  static const supportedLocales = [EN_LOCALE, TR_LOCALE];

  static const languagesMap = {
    'en': EN_LOCALE,
    'tr': TR_LOCALE,
  };
}