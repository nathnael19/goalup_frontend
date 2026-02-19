import 'package:bloc/bloc.dart';
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

  Future<void> fetchTournament(String? id) async {
    if (id == null) return;
    try {
      emit(TournamentLoading());
      final tournament = await _apiService.getTournament(
        id,
        forceRefresh: true,
      );

      // Fetch all seasons for this competition
      List<Tournament> seasons = [];
      if (tournament.competitionId != null) {
        seasons = await _apiService.getCompetitionSeasons(
          tournament.competitionId!,
        );
        // Sort by year descending
        seasons.sort((a, b) => b.year.compareTo(a.year));
      }

      emit(TournamentLoaded(tournament, seasons: seasons));
    } catch (e) {
      emit(TournamentError(e.toString()));
    }
  }
}
