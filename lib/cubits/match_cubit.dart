import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/match.dart';
import '../services/api_service.dart';

abstract class MatchState {}

class MatchInitial extends MatchState {}

class MatchLoading extends MatchState {}

class MatchLoaded extends MatchState {
  final List<Match> matches;
  MatchLoaded(this.matches);
}

class MatchError extends MatchState {
  final String message;
  MatchError(this.message);
}

class MatchCubit extends Cubit<MatchState> {
  final ApiService apiService;

  MatchCubit(this.apiService) : super(MatchInitial());

  Future<void> fetchMatches({bool forceRefresh = false}) async {
    try {
      // 1. Try to load from cache first for instant UI
      if (!forceRefresh) {
        final cachedData = await apiService.getCached('/matches/');
        if (cachedData != null) {
          final cachedMatches = (cachedData as List)
              .map((json) => Match.fromJson(json))
              .toList();
          emit(MatchLoaded(cachedMatches));
        } else {
          emit(MatchLoading());
        }
      } else {
        emit(MatchLoading());
      }

      // 2. Fetch fresh data from network
      final matches = await apiService.getMatches(forceRefresh: forceRefresh);
      emit(MatchLoaded(matches));
    } catch (e) {
      // If we already emitted a cached Loaded state, we might not want to emit Error
      // unless it's a critical failure and no data exists.
      if (state is! MatchLoaded) {
        emit(MatchError(e.toString()));
      }
    }
  }

  // Filter methods can be added here
  List<Match> getLiveMatches(List<Match> allMatches) {
    return allMatches.where((m) => m.status == MatchStatus.live).toList();
  }

  List<Match> getUpcomingMatches(List<Match> allMatches) {
    return allMatches.where((m) => m.status == MatchStatus.scheduled).toList();
  }
}
