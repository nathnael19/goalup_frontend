import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/api_service.dart';

abstract class StandingsState {}

class StandingsInitial extends StandingsState {}

class StandingsLoading extends StandingsState {}

class StandingsLoaded extends StandingsState {
  final List<dynamic> tournaments;
  StandingsLoaded(this.tournaments);
}

class StandingsError extends StandingsState {
  final String message;
  StandingsError(this.message);
}

class StandingsCubit extends Cubit<StandingsState> {
  final ApiService apiService;

  StandingsCubit(this.apiService) : super(StandingsInitial());

  Future<void> fetchStandings() async {
    try {
      emit(StandingsLoading());
      final standings = await apiService.getStandings();
      emit(StandingsLoaded(standings));
    } catch (e) {
      emit(StandingsError(e.toString()));
    }
  }
}
