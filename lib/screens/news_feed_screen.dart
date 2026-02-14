import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/news_cubit.dart';
import '../models/news.dart';
import '../widgets/filter_chips.dart';
import '../widgets/news_card.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'transfer',
    'injury',
    'general',
    'match_report',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        if (state is NewsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.red),
          );
        }

        if (state is NewsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(state.message, style: const TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () => context.read<NewsCubit>().fetchNews(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is NewsLoaded) {
          final news = state.news;
          final filteredNews = _selectedCategory == 'All'
              ? news
              : news.where((n) => n.category == _selectedCategory).toList();

          return Scaffold(
            body: RefreshIndicator(
              onRefresh: () => context.read<NewsCubit>().fetchNews(),
              color: Colors.red,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: FilterChips(
                        categories: _categories,
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    ),
                  ),
                  if (filteredNews.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No news articles found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return NewsCard(news: filteredNews[index]);
                        }, childCount: filteredNews.length),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
