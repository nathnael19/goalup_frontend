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

  Future<void> fetchMatches() async {
    try {
      emit(MatchLoading());
      final matches = await apiService.getMatches();
      emit(MatchLoaded(matches));
    } catch (e) {
      emit(MatchError(e.toString()));
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
