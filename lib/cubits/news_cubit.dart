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

  Future<void> fetchNews({String? category, bool forceRefresh = false}) async {
    try {
      // 1. Try to load from cache first for instant UI
      if (!forceRefresh) {
        final endpoint = category != null && category != 'All'
            ? '/news/?category=$category'
            : '/news/';
        final cachedData = await _apiService.getCached(endpoint);

        if (cachedData != null) {
          final List<News> cachedNews = List<dynamic>.from(
            cachedData,
          ).map((json) => News.fromJson(json)).toList();
          emit(NewsLoaded(cachedNews));
        } else {
          emit(NewsLoading());
        }
      } else {
        emit(NewsLoading());
      }

      // 2. Fetch fresh data from network
      final List<dynamic> newsJson = await _apiService.getNews(
        category: category,
        forceRefresh: forceRefresh,
      );
      final List<News> news = newsJson
          .map((json) => News.fromJson(json))
          .toList();
      emit(NewsLoaded(news));
    } catch (e) {
      if (state is! NewsLoaded) {
        emit(NewsError(e.toString()));
      }
    }
  }
}
