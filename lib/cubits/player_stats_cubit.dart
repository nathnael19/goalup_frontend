import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/player.dart';
import '../models/team.dart';
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

  PlayerStatsCubit(this.apiService) : super(PlayerStatsInitial());

  Future<void> fetchPlayerStats({
    String? tournamentId,
    String? competitionId,
    bool forceRefresh = false,
  }) async {
    try {
      // 1. Try to load from cache first for instant UI
      if (!forceRefresh) {
        final cachedPlayersData = await apiService.getCached('/players/');
        final cachedTeamsData = await apiService.getCached('/teams/');

        if (cachedPlayersData != null && cachedTeamsData != null) {
          final allPlayers = (cachedPlayersData as List)
              .map((p) => Player.fromJson(p))
              .toList();
          final allTeams = (cachedTeamsData as List)
              .map((t) => Team.fromJson(t))
              .toList();

          final teamMap = {for (var t in allTeams) t.id: t.name};
          final filteredPlayers = _filterPlayers(
            allPlayers,
            allTeams,
            tournamentId,
            competitionId,
          );

          if (filteredPlayers.isNotEmpty) {
            emit(
              PlayerStatsLoaded(
                players: filteredPlayers,
                teamMap: teamMap,
                tournamentId: tournamentId,
              ),
            );
          } else {
            emit(PlayerStatsLoading());
          }
        } else {
          emit(PlayerStatsLoading());
        }
      } else {
        emit(PlayerStatsLoading());
      }

      // 2. Fetch fresh data from network
      final playersJson = await apiService.getPlayers(
        forceRefresh: forceRefresh,
      );
      final teams = await apiService.getTeams(forceRefresh: forceRefresh);

      final allPlayers = playersJson.map((p) => Player.fromJson(p)).toList();
      final teamMap = {for (var t in teams) t.id: t.name};
      final filteredPlayers = _filterPlayers(
        allPlayers,
        teams,
        tournamentId,
        competitionId,
      );

      emit(
        PlayerStatsLoaded(
          players: filteredPlayers,
          teamMap: teamMap,
          tournamentId: tournamentId,
        ),
      );
    } catch (e) {
      if (state is! PlayerStatsLoaded) {
        emit(PlayerStatsError(e.toString()));
      }
    }
  }

  List<Player> _filterPlayers(
    List<Player> players,
    List<Team> teams,
    String? tournamentId,
    String? competitionId,
  ) {
    if (tournamentId == null && competitionId == null) return players;

    final filteredTeamIds = teams
        .where(
          (t) =>
              (tournamentId != null &&
                  (t.tournament?.id == tournamentId ||
                      t.standings?.any((s) => s.tournamentId == tournamentId) ==
                          true)) ||
              (competitionId != null &&
                  t.tournament?.competition?.id == competitionId),
        )
        .map((t) => t.id)
        .toSet();

    return players.where((p) => filteredTeamIds.contains(p.teamId)).toList();
  }

  void reset() {
    emit(PlayerStatsInitial());
  }
}
