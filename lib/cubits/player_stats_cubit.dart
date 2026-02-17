import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/player.dart';
import '../services/api_service.dart';

abstract class PlayerStatsState {}

class PlayerStatsInitial extends PlayerStatsState {}

class PlayerStatsLoading extends PlayerStatsState {}

class PlayerStatsLoaded extends PlayerStatsState {
  final List<Player> players;
  final Map<String, String> teamMap;
  final String? tournamentId;

  PlayerStatsLoaded({
    required this.players,
    required this.teamMap,
    this.tournamentId,
  });
}

class PlayerStatsError extends PlayerStatsState {
  final String message;
  PlayerStatsError(this.message);
}

class PlayerStatsCubit extends Cubit<PlayerStatsState> {
  final ApiService apiService;

  // Cache to avoid redundant fetches
  List<Player>? _allPlayers;
  Map<String, String>? _teamMap;

  PlayerStatsCubit(this.apiService) : super(PlayerStatsInitial());

  Future<void> fetchPlayerStats({
    String? tournamentId,
    String? competitionId,
  }) async {
    try {
      if (state is PlayerStatsLoading) return;

      emit(PlayerStatsLoading());

      // Fetch teams first for the mapping if not cached
      if (_teamMap == null) {
        final teams = await apiService.getTeams();
        _teamMap = {for (var t in teams) t.id: t.name};
      }

      // Fetch all players if not cached
      if (_allPlayers == null) {
        final playersJson = await apiService.getPlayers();
        _allPlayers = playersJson.map((json) => Player.fromJson(json)).toList();
      }

      List<Player> filteredPlayers = _allPlayers!;

      if (tournamentId != null || competitionId != null) {
        // Fetch teams to get tournament/competition association
        final teams = await apiService.getTeams();
        final filteredTeamIds = teams
            .where(
              (t) =>
                  (tournamentId != null &&
                      (t.tournament?.id == tournamentId ||
                          t.standings?.any(
                                (s) => s.tournamentId == tournamentId,
                              ) ==
                              true)) ||
                  (competitionId != null &&
                      t.tournament?.competition?.id == competitionId),
            )
            .map((t) => t.id)
            .toSet();

        filteredPlayers = _allPlayers!
            .where((p) => filteredTeamIds.contains(p.teamId))
            .toList();
      }

      emit(
        PlayerStatsLoaded(
          players: filteredPlayers,
          teamMap: _teamMap!,
          tournamentId: tournamentId,
        ),
      );
    } catch (e) {
      emit(PlayerStatsError(e.toString()));
    }
  }

  void reset() {
    _allPlayers = null;
    _teamMap = null;
    emit(PlayerStatsInitial());
  }
}
