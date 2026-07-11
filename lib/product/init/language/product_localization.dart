import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'locale.dart'; 

@immutable
final class ProductLocalization extends EasyLocalization {
  ProductLocalization({required super.child, super.key})
      : super(
          supportedLocales: AppConstants.supportedLocales,
          path: AppConstants.LANG_PATH,
          fallbackLocale: AppConstants.EN_LOCALE,
          saveLocale: true,
        );
}