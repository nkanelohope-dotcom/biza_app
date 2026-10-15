import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'settings_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const BizaApp());
}

class BizaApp extends StatefulWidget {
  const BizaApp({super.key});
  @override
  State<BizaApp> createState() => _BizaAppState();
}

class _BizaAppState extends State<BizaApp> {
  AppSettings _settings = AppSettings();

  void _updateSettings(AppSettings s) {
    setState(() => _settings = s);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsProvider(
      settings: _settings,
      updateSettings: _updateSettings,
      child: MaterialApp(
        title: 'BIZA Security',
        debugShowCheckedModeBanner: false,
        theme: _settings.darkMode ? BizaTheme.darkTheme : BizaTheme.lightTheme,
        home: const SplashScreen(),
        themeAnimationDuration: const Duration(milliseconds: 250),
        themeAnimationCurve: Curves.easeInOut,
      ),
    );
  }
}