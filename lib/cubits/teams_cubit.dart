import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/team.dart';
import '../services/api_service.dart';

abstract class TeamsState {}

class TeamsInitial extends TeamsState {}

class TeamsLoading extends TeamsState {}

class TeamsLoaded extends TeamsState {
  final List<Team> teams;
  TeamsLoaded(this.teams);
}

class TeamsError extends TeamsState {
  final String message;
  TeamsError(this.message);
}

class TeamsCubit extends Cubit<TeamsState> {
  final ApiService apiService;

  TeamsCubit(this.apiService) : super(TeamsInitial());

  Future<void> fetchTeams({bool forceRefresh = false}) async {
    try {
      // 1. Try to load from cache first for instant UI
      if (!forceRefresh) {
        final cachedData = await apiService.getCached('/teams/');
        if (cachedData != null) {
          final cachedTeams = (cachedData as List)
              .map((json) => Team.fromJson(json))
              .toList();
          emit(TeamsLoaded(cachedTeams));
        } else {
          emit(TeamsLoading());
        }
      } else {
        emit(TeamsLoading());
      }

      // 2. Fetch fresh data from network
      final teams = await apiService.getTeams(forceRefresh: forceRefresh);
      emit(TeamsLoaded(teams));
    } catch (e) {
      if (state is! TeamsLoaded) {
        emit(TeamsError(e.toString()));
      }
    }
  }
}
