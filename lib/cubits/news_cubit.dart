import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/news.dart';
import '../services/api_service.dart';

abstract class NewsState {}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<News> news;
  NewsLoaded(this.news);
}

class NewsError extends NewsState {
  final String message;
  NewsError(this.message);
}

class NewsCubit extends Cubit<NewsState> {
  final ApiService _apiService;

  NewsCubit(this._apiService) : super(NewsInitial());

  Future<void> fetchNews() async {
    emit(NewsLoading());
    try {
      final List<dynamic> newsJson = await _apiService.getNews();
      final List<News> news = newsJson
          .map((json) => News.fromJson(json))
          .toList();
      emit(NewsLoaded(news));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }
}
