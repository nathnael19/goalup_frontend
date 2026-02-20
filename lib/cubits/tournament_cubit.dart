import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/tournament.dart';
import '../services/api_service.dart';

abstract class TournamentState extends Equatable {
  const TournamentState();

  @override
  List<Object> get props => [];
}

class TournamentInitial extends TournamentState {}

class TournamentLoading extends TournamentState {}

class TournamentLoaded extends TournamentState {
  final Tournament tournament;
  final List<Tournament> seasons;

  const TournamentLoaded(this.tournament, {this.seasons = const []});

  @override
  List<Object> get props => [tournament, seasons];
}

class TournamentError extends TournamentState {
  final String message;

  const TournamentError(this.message);

  @override
  List<Object> get props => [message];
}

class TournamentCubit extends Cubit<TournamentState> {
  final ApiService _apiService;

  TournamentCubit({ApiService? apiService})
    : _apiService = apiService ?? ApiService(),
      super(TournamentInitial());

  Future<void> fetchTournament(String? id, {bool forceRefresh = false}) async {
    if (id == null) return;
    try {
      // 1. Try to load from cache first for instant UI
      if (!forceRefresh) {
        final cachedTournamentData = await _apiService.getCached(
          '/tournaments/$id',
        );
        final cachedSeasonsData = await _apiService.getCached('/tournaments/');

        if (cachedTournamentData != null) {
          final tournament = Tournament.fromJson(cachedTournamentData);
          List<Tournament> seasons = [];

          if (cachedSeasonsData != null) {
            seasons = (cachedSeasonsData as List)
                .map((json) => Tournament.fromJson(json))
                .where((t) => t.competitionId == tournament.competitionId)
                .toList();
            seasons.sort((a, b) => b.year.compareTo(a.year));
          }

          emit(TournamentLoaded(tournament, seasons: seasons));
        } else {
          emit(TournamentLoading());
        }
      } else {
        emit(TournamentLoading());
      }

      // 2. Fetch fresh data from network
      final tournament = await _apiService.getTournament(
        id,
        forceRefresh: forceRefresh,
      );

      // Fetch all seasons for this competition
      List<Tournament> seasons = [];
      if (tournament.competitionId != null) {
        seasons = await _apiService.getCompetitionSeasons(
          tournament.competitionId!,
          forceRefresh: forceRefresh,
        );
        // Sort by year descending
        seasons.sort((a, b) => b.year.compareTo(a.year));
      }

      emit(TournamentLoaded(tournament, seasons: seasons));
    } catch (e) {
      if (state is! TournamentLoaded) {
        emit(TournamentError(e.toString()));
      }
    }
  }
}
