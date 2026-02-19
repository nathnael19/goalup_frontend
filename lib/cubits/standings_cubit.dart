import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/api_service.dart';

abstract class StandingsState {}

class StandingsInitial extends StandingsState {}

class StandingsLoading extends StandingsState {}

class StandingsLoaded extends StandingsState {
  final List<Map<String, dynamic>> tournaments;
  StandingsLoaded(this.tournaments);
}

class StandingsError extends StandingsState {
  final String message;
  StandingsError(this.message);
}

class StandingsCubit extends Cubit<StandingsState> {
  final ApiService apiService;

  StandingsCubit(this.apiService) : super(StandingsInitial());

  Future<void> fetchStandings({
    String? tournamentId,
    bool forceRefresh = false,
  }) async {
    try {
      // 1. Try to load from cache first for instant UI
      if (!forceRefresh) {
        final endpoint = tournamentId != null
            ? '/standings/$tournamentId'
            : '/standings/';
        final cachedData = await apiService.getCached(endpoint);

        if (cachedData != null) {
          if (tournamentId != null) {
            emit(StandingsLoaded([cachedData as Map<String, dynamic>]));
          } else {
            emit(StandingsLoaded(List<Map<String, dynamic>>.from(cachedData)));
          }
        } else {
          emit(StandingsLoading());
        }
      } else {
        emit(StandingsLoading());
      }

      // 2. Fetch fresh data from network
      if (tournamentId != null) {
        final standings = await apiService.getTournamentStandings(
          tournamentId,
          forceRefresh: forceRefresh,
        );
        emit(StandingsLoaded([standings]));
      } else {
        final standingsArr = await apiService.getStandings(
          forceRefresh: forceRefresh,
        );
        emit(StandingsLoaded(List<Map<String, dynamic>>.from(standingsArr)));
      }
    } catch (e) {
      if (state is! StandingsLoaded) {
        emit(StandingsError(e.toString()));
      }
    }
  }
}
