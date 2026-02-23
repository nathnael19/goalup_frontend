import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'cubits/match_cubit.dart';
import 'cubits/standings_cubit.dart';
import 'cubits/teams_cubit.dart';
import 'cubits/news_cubit.dart';
import 'cubits/notification_cubit.dart';
import 'cubits/navigation_cubit.dart';
import 'cubits/player_stats_cubit.dart';
import 'services/ad_service.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  try {
    final firebaseApiKey = dotenv.env['FIREBASE_API_KEY'];
    final firebaseAppId = dotenv.env['FIREBASE_APP_ID'];
    final firebaseMessagingSenderId =
        dotenv.env['FIREBASE_MESSAGING_SENDER_ID'];
    final firebaseProjectId = dotenv.env['FIREBASE_PROJECT_ID'];

    if (firebaseApiKey != null &&
        firebaseApiKey != 'your_api_key_here' &&
        firebaseAppId != null) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: firebaseApiKey,
          appId: firebaseAppId,
          messagingSenderId: firebaseMessagingSenderId ?? '',
          projectId: firebaseProjectId ?? '',
        ),
      );
      // ignore: avoid_print
      print('Firebase initialized programmatically from .env');
    } else {
      await Firebase.initializeApp();
      // ignore: avoid_print
      print('Firebase initialized from native configuration');
    }
  } catch (e) {
    // ignore: avoid_print
    print('Firebase initialization failed: $e');
  }

  final apiService = ApiService();
  final notificationService = NotificationService();
  final adService = AdService();

  // Initialize AdMob and Notifications asynchronously to avoid blocking startup
  unawaited(adService.initialize());
  unawaited(notificationService.init());

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiService),
        RepositoryProvider.value(value: adService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => MatchCubit(apiService)..fetchMatches(),
          ),
          BlocProvider(create: (context) => StandingsCubit(apiService)),
          BlocProvider(create: (context) => TeamsCubit(apiService)),
          BlocProvider(create: (context) => NewsCubit(apiService)..fetchNews()),
          BlocProvider(create: (context) => NavigationCubit()),
          BlocProvider(
            create: (context) =>
                NotificationCubit(apiService, notificationService),
          ),
          BlocProvider(create: (context) => PlayerStatsCubit(apiService)),
        ],
        child: GoalUpApp(notificationService: notificationService),
      ),
    ),
  );
}

/// Main application widget for GoalUp - ASTU Football App
class GoalUpApp extends StatefulWidget {
  const GoalUpApp({super.key, required this.notificationService});

  final NotificationService notificationService;

  @override
  State<GoalUpApp> createState() => _GoalUpAppState();
}

class _GoalUpAppState extends State<GoalUpApp> {
  @override
  void initState() {
    super.initState();
    // Notification initialization moved to main() for earlier initialization
    // but kept here as a fallback if needed, or removed if handled in main.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoalUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE53935), // Red
          onPrimary: Colors.white,
          surface: Color(0xFF0A0A0A), // Deeper Black
          onSurface: Colors.white,
          surfaceContainer: Color(0xFF1A1A1A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        appBarTheme: const AppBarTheme(
          centerTitle:
              false, // Changed to match design of many news apps, but home_screen has its own title
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: const Color(0xFF1A1A1A),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF0A0A0A),
          elevation: 0,
          indicatorColor:
              Colors.transparent, // We'll manage selection via colors
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              );
            }
            return const TextStyle(color: Colors.grey, fontSize: 11);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFFE53935), size: 26);
            }
            return const IconThemeData(color: Colors.grey, size: 24);
          }),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
