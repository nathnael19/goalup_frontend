import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/news_cubit.dart';
import '../widgets/filter_chips.dart';
import '../widgets/news_card.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  String _selectedCategoryLabel = 'All';

  final Map<String, String?> _categoryMap = {
    'All': null,
    'Transfer': 'transfer',
    'Injury': 'injury',
    'General': 'general',
    'Match Report': 'match_report',
  };

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
                  onPressed: () => context.read<NewsCubit>().fetchNews(
                    category: _categoryMap[_selectedCategoryLabel],
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is NewsLoaded) {
          final news = state.news;
          // Filtering is now handled by the backend request, so news is already filtered.

          return Scaffold(
            body: RefreshIndicator(
              onRefresh: () => context.read<NewsCubit>().fetchNews(
                category: _categoryMap[_selectedCategoryLabel],
              ),
              color: Colors.red,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: FilterChips(
                        categories: _categoryMap.keys.toList(),
                        selectedCategory: _selectedCategoryLabel,
                        onCategorySelected: (label) {
                          setState(() {
                            _selectedCategoryLabel = label;
                          });
                          context.read<NewsCubit>().fetchNews(
                            category: _categoryMap[label],
                          );
                        },
                      ),
                    ),
                  ),
                  if (news.isEmpty)
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
                          return NewsCard(news: news[index]);
                        }, childCount: news.length),
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
