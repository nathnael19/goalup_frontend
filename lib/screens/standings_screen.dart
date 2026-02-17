import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/standings_cubit.dart';
import '../models/standing.dart' as model;
import '../widgets/standings_table.dart';
import '../utils/responsive.dart';

/// Standings Screen displaying tournament leaderboards
class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  @override
  void initState() {
    super.initState();
    final standingsCubit = context.read<StandingsCubit>();
    if (standingsCubit.state is! StandingsLoaded) {
      standingsCubit.fetchStandings();
    }
  }

  Future<void> _handleRefresh() async {
    await context.read<StandingsCubit>().fetchStandings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'STANDINGS',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      body: BlocBuilder<StandingsCubit, StandingsState>(
        builder: (context, state) {
          if (state is StandingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StandingsLoaded) {
            if (state.tournaments.isEmpty) {
              return _buildEmptyStandingsState();
            }

            // Global standings shows the first tournament's standings for now
            final List<dynamic> teamsJson = state.tournaments[0]['teams'];
            final List<model.Standing> standings = teamsJson
                .map((s) => model.Standing.fromJson(s))
                .toList();

            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: StandingsTable(standings: standings),
            );
          } else if (state is StandingsError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyStandingsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: 80.sp,
            color: Colors.grey[800],
          ),
          SizedBox(height: 16.h),
          Text(
            'NO STANDINGS FOUND',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13.sp,
              letterSpacing: 1,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
