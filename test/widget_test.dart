import 'package:archis_academy/features/auth/view/login_view.dart';
import 'package:archis_academy/features/auth/view/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpApp(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: widget),
    ),
  );
  await tester.pump(); 
}
void main() {
  testWidgets('Login formu değerleri kabul ediyor', (tester) async {
    await pumpApp(tester, const LoginView()); 

    expect(find.byType(TextFormField), findsNWidgets(2));
    await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
    await tester.pump();
  });

testWidgets('Register sayfası form alanlarını ve etkileşimi kontrol et', (tester) async {
  await pumpApp(tester, const RegisterView());

  final formFields = find.byType(TextFormField);
  expect(formFields, findsNWidgets(4)); 

  await tester.enterText(formFields.at(0), 'Adım');
  await tester.enterText(formFields.at(1), 'Soyadım');
  await tester.enterText(formFields.at(2), 'test@test.com');
  await tester.enterText(formFields.at(3), '123456');

  expect(find.text('Adım'), findsOneWidget);
  expect(find.text('test@test.com'), findsOneWidget);
});
}