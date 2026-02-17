import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/standings_cubit.dart';
import '../../models/standing.dart' as standing_model;
import '../../utils/responsive.dart';

class TeamStatsTab extends StatelessWidget {
  final String? competitionId;
  final String? tournamentId;
  const TeamStatsTab({super.key, this.competitionId, this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StandingsCubit, StandingsState>(
      builder: (context, state) {
        if (state is StandingsLoaded && state.tournaments.isNotEmpty) {
          final tournamentData = state.tournaments.firstWhere(
            (t) =>
                (tournamentId != null &&
                    t['tournament']['id'] == tournamentId) ||
                (competitionId != null &&
                    t['tournament']['competition']?['id'] == competitionId),
            orElse: () => state.tournaments[0],
          );

          final List<dynamic> teamsJson = tournamentData['teams'];
          final List<standing_model.Standing> standings = teamsJson
              .map((s) => standing_model.Standing.fromJson(s))
              .toList();

          final bestAttack = List<standing_model.Standing>.from(standings);
          bestAttack.sort((a, b) => b.goalsFor.compareTo(a.goalsFor));

          final bestDefense = List<standing_model.Standing>.from(standings);
          bestDefense.sort((a, b) => a.goalsAgainst.compareTo(b.goalsAgainst));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('Best Attack'),
              ...bestAttack
                  .take(3)
                  .map(
                    (s) => _buildStatRow(
                      s.team?.name ?? 'Unknown',
                      s.goalsFor.toString(),
                      'Goals Scored',
                    ),
                  ),
              const SizedBox(height: 24),
              _buildSectionHeader('Best Defense'),
              ...bestDefense
                  .take(3)
                  .map(
                    (s) => _buildStatRow(
                      s.team?.name ?? 'Unknown',
                      s.goalsAgainst.toString(),
                      'Goals Conceded',
                    ),
                  ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
      ),
    );
  }

  Widget _buildStatRow(String teamName, String value, String label) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(teamName, style: const TextStyle(fontWeight: FontWeight.bold)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
