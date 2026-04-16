import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:royal_fitness/app.dart';
import 'package:royal_fitness/core/di/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboarding_completed': true,
    });
    await EasyLocalization.ensureInitialized();
  });

  setUp(() async {
    await getIt.reset();
    configureDependencies();
  });

  testWidgets('Login shows localized welcome title', (tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const TickerMode(
          enabled: false,
          child: RoyalFitnessApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
