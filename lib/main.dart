import 'package:flutter/material.dart';
import 'common.dart';
import 'garage_page.dart';

void main() => runApp(const KulmaApp());

class KulmaApp extends StatelessWidget {
  const KulmaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kulmaproto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: kPrimary,
          surface: kCard,
          background: kBg,
          onSurface: kTextMain,
        ),
        scaffoldBackgroundColor: kBg,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: kCard,
          contentTextStyle: TextStyle(color: kTextMain),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: kTextMain, fontSize: 16),
          labelSmall: TextStyle(color: kTextMuted, fontSize: 12),
          titleMedium: TextStyle(color: kTextMain, fontWeight: FontWeight.w600),
        ),
      ),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final w = mq.size.width;
        double maxScale;
        if (w < 360) {
          maxScale = 0.95;
        } else if (w < 400) {
          maxScale = 1.0;
        } else if (w < 700) {
          maxScale = 1.05;
        } else {
          maxScale = 1.2;
        }
        final clamped = mq.textScaleFactor.clamp(0.9, maxScale);
        return MediaQuery(data: mq.copyWith(textScaleFactor: clamped), child: child ?? const SizedBox());
      },
      home: const GaragePage(),
    );
  }
}
