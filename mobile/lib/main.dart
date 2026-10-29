import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/app_theme.dart';
import 'widgets/app_header.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SahhefApp());
}

class SahhefApp extends StatefulWidget {
  const SahhefApp({super.key});

  @override
  State<SahhefApp> createState() => _SahhefAppState();
}

class _SahhefAppState extends State<SahhefApp> {
  bool _isArabic = true;
  bool _isDarkMode = false;

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _isArabic ? 'صَحِّف | Journal it' : 'Journal it',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      ),
      locale: _isArabic ? const Locale('ar', 'AE') : const Locale('en', 'US'),
      supportedLocales: const [
        Locale('ar', 'AE'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        appBar: AppHeader(
          isArabic: _isArabic,
          isDarkMode: _isDarkMode,
          onToggleLanguage: _toggleLanguage,
          onToggleTheme: _toggleTheme,
        ),
        body: HomeScreen(
          isArabic: _isArabic,
          isDarkMode: _isDarkMode,
          onToggleLanguage: _toggleLanguage,
          onToggleTheme: _toggleTheme,
        ),
      ),
    );
  }
}
