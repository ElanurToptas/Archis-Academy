import 'dart:convert';
import 'dart:io';
import 'package:translator/translator.dart';

Future<void> main() async {
  final projectRoot = Directory.current.path;
  final enFile = File('$projectRoot/assets/translations/en.json');
  final trFile = File('$projectRoot/assets/translations/tr.json');

  final enJson = jsonDecode(await enFile.readAsString()) as Map<String, dynamic>;
  final trJson = await trFile.exists() ? jsonDecode(await trFile.readAsString()) as Map<String, dynamic> : <String, dynamic>{};

  final translator = GoogleTranslator();

  for (final entry in enJson.entries) {
    if (trJson[entry.key] == null || trJson[entry.key].toString().isEmpty) {
      final t = await translator.translate(entry.value.toString(), from: 'en', to: 'tr');
      trJson[entry.key] = t.text;
      print('Translated: ${entry.key} -> ${t.text}');
    }
  }

  final encoder = const JsonEncoder.withIndent('  ');
  await trFile.writeAsString(encoder.convert(trJson));
  print('Translation completed.');
}