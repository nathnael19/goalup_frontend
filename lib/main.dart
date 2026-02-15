import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/match_cubit.dart';
import 'cubits/standings_cubit.dart';
import 'cubits/teams_cubit.dart';
import 'cubits/news_cubit.dart';
import 'cubits/notification_cubit.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    RepositoryProvider.value(
      value: apiService,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => MatchCubit(apiService)..fetchMatches(),
          ),
          BlocProvider(
            create: (context) => StandingsCubit(apiService)..fetchStandings(),
          ),
          BlocProvider(
            create: (context) => TeamsCubit(apiService)..fetchTeams(),
          ),
          BlocProvider(create: (context) => NewsCubit(apiService)..fetchNews()),
          BlocProvider(
            create: (context) =>
                NotificationCubit(apiService, notificationService)
                  ..fetchNotifications(),
          ),
        ],
        child: const GoalUpApp(),
      ),
    ),
  );
}

/// Main application widget for GoalUp - ASTU Football App
class GoalUpApp extends StatelessWidget {
  const GoalUpApp({super.key});

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
