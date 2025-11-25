import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'services/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();

  static _ExpenseTrackerAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_ExpenseTrackerAppState>();
  }
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _locale = Locale(prefs.getString('language') ?? 'en');
      _themeMode = (prefs.getBool('darkMode') ?? false)
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  void setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
  }

  void setThemeMode(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', mode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',

      // Theme
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _themeMode,

      // Localization
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
        Locale('zh'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const HomeScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1976D2), // Rich blue
        secondary: Color(0xFFFF9800), // Orange accent
        tertiary: Color(0xFF4CAF50), // Green
        surface: Colors.white, // Light blue background
        error: Color(0xFFE53935),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1A237E),
        surfaceContainerHighest: Color(0xFFBBDEFB),
      ),
      scaffoldBackgroundColor: const Color(0xFFE3F2FD),
      cardTheme: CardThemeData(
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        color: Colors.white,
        shadowColor: const Color(0xFF1976D2).withOpacity(0.2),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 12,
        backgroundColor: Color(0xFFFF9800), // Orange FAB
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1976D2),
        indicatorColor: const Color(0xFFFF9800).withOpacity(0.3),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: Color(0xFFFF9800),
            ); // Orange when selected
          }
          return const IconThemeData(
            color: Color(0xFF90CAF9),
          ); // Light blue when not selected
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: Color(0xFFFF9800),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(color: Color(0xFF90CAF9), fontSize: 12);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1976D2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF90CAF9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF1A237E)),
        bodyMedium: TextStyle(color: Color(0xFF283593)),
        bodySmall: TextStyle(color: Color(0xFF5C6BC0)),
        titleLarge: TextStyle(
          color: Color(0xFF0D47A1),
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF1565C0),
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(color: Color(0xFF1976D2)),
      ),
      dividerColor: const Color(0xFFBBDEFB),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF1976D2),
        linearTrackColor: Color(0xFFBBDEFB),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7C3AED), // Vibrant purple
        secondary: Color(0xFF06B6D4), // Cyan
        tertiary: Color(0xFFEC4899), // Pink
        surface: Color(0xFF1E1B2E), // Dark blue-black
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFE2E8F0),
        surfaceContainerHighest: Color(0xFF2D2640), // Lighter purple
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      cardTheme: CardThemeData(
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: const Color(0xFF1E1B2E),
        shadowColor: const Color(0xFF7C3AED).withOpacity(0.3), // Purple glow
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF06B6D4)), // Cyan icons
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 12,
        backgroundColor: Color(0xFF7C3AED), // Purple FAB
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1B2E),
        indicatorColor: const Color(0xFF7C3AED).withOpacity(0.3),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: Color(0xFF06B6D4),
            ); // Cyan when selected
          }
          return const IconThemeData(
            color: Color(0xFF64748B),
          ); // Gray when not selected
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: Color(0xFF06B6D4),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(color: Color(0xFF64748B), fontSize: 12);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2640),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4C1D95)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFE2E8F0)),
        bodyMedium: TextStyle(color: Color(0xFFCBD5E1)),
        bodySmall: TextStyle(color: Color(0xFF94A3B8)),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(
          color: Color(0xFFE2E8F0),
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(color: Color(0xFFCBD5E1)),
      ),
      dividerColor: const Color(0xFF2D2640),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF7C3AED),
        linearTrackColor: Color(0xFF2D2640),
      ),
    );
  }
}
