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

  Future<void> fetchTeams() async {
    try {
      emit(TeamsLoading());
      final teams = await apiService.getTeams();
      emit(TeamsLoaded(teams));
    } catch (e) {
      emit(TeamsError(e.toString()));
    }
  }
}
