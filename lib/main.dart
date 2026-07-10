import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qirshity/views/splash/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('qirshityBox');
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('qirshityBox').listenable(),
      builder: (context, box, widget) {
        bool isDarkMode = box.get("isDarkMode", defaultValue: false);
        int colorValue = box.get("primaryColor", defaultValue: 0xFFB99BFF);
        Color primaryAppColor = Color(colorValue);

        return MaterialApp(
          title: 'قرشيتي',
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar')],
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: primaryAppColor,
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            fontFamily: "Alexandria",
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: primaryAppColor,
            fontFamily: "Alexandria",
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),
          home: const SplashView(),
        );
      },
    );
  }
}
