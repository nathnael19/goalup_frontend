import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/match_cubit.dart';
import 'cubits/standings_cubit.dart';
import 'cubits/teams_cubit.dart';
import 'services/api_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    RepositoryProvider(
      create: (context) => ApiService(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                MatchCubit(context.read<ApiService>())..fetchMatches(),
          ),
          BlocProvider(
            create: (context) =>
                StandingsCubit(context.read<ApiService>())..fetchStandings(),
          ),
          BlocProvider(
            create: (context) =>
                TeamsCubit(context.read<ApiService>())..fetchTeams(),
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
          surface: const Color(0xFF121212),
          surfaceContainer: const Color(0xFF1E1E1E),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF121212),
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFF1E1E1E),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF121212),
          indicatorColor: const Color(0xFF2196F3).withValues(alpha: 0.2),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: Color(0xFF2196F3),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
            }
            return const TextStyle(color: Colors.grey, fontSize: 12);
          }),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
