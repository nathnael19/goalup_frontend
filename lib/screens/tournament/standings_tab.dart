import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/standings_cubit.dart';
import '../../models/standing.dart' as standing_model;
import '../../widgets/standings_table.dart';

class StandingsTab extends StatelessWidget {
  final String? competitionId;
  final String? tournamentId;

  const StandingsTab({super.key, this.competitionId, this.tournamentId});

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
          return StandingsTable(standings: standings);
        }
        if (state is StandingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Center(child: Text('No standings data'));
      },
    );
  }
}
