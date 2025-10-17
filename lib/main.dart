import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Core imports
import 'core/themes/app_theme.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/print_provider.dart';
import 'providers/theme_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/student/home_screen.dart';
import 'screens/printer/printer_dashboard_screen.dart';
import 'screens/printer/printer_home_screen.dart'; // ✅ new printer home

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Set transparent status bar with dynamic brightness
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(const PrintManagerApp());
}

class PrintManagerApp extends StatelessWidget {
  const PrintManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PrintProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final isDark = themeProvider.isDarkMode;

          return AnimatedTheme(
            data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
            duration: const Duration(milliseconds: 300), // smooth fade
            curve: Curves.easeInOut,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Student Printing System',

              // Themed configurations
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,

              // ✅ Routes
              routes: {
                AppRoutes.login: (context) => const LoginScreen(),
                AppRoutes.home: (context) => const HomeScreen(),
                AppRoutes.printerDashboard: (context) => const PrinterDashboardScreen(),
                '/printer_home': (context) => const PrinterHomeScreen(), // ✅ added
              },

              // Entry point
              home: const AppEntryPoint(),
            ),
          );
        },
      ),
    );
  }
}

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _initialized = true;
      setState(() {});
    } catch (_) {
      _error = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (_error) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text('Something went wrong!'),
            ],
          ),
        ),
      );
    }

    // Splash / Loading
    if (!_initialized || authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    // Role-based navigation
    if (authProvider.user != null) {
      if (authProvider.isPrinter) {
        return const PrinterHomeScreen(); // ✅ Printer
      } else if (authProvider.isStudent) {
        return const HomeScreen(); // ✅ Student
      }
    }

    // Default: Login
    return const LoginScreen();
  }
}
