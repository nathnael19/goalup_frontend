import 'package:flutter/material.dart';
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
    'Match',
    'Club',
    'Transfer',
    'Injury',
  ];

  final List<News> _allNews = [
    News(
      id: '1',
      title: 'Late winner seals dramatic derby victory',
      category: 'Match',
      date: DateTime(2025, 12, 3),
      description:
          'A last-minute strike sent the stadium wild as Arsenal snatched victory in the dying seconds...',
      imageUrl:
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=2000&auto=format&fit=crop',
      reporterName: 'John Doe',
    ),
    News(
      id: '2',
      title: 'Midfield maestro signs new contract',
      category: 'Club',
      date: DateTime(2025, 11, 29),
      description:
          'The club confirmed today that the captain has extended his stay with an improved deal...',
      imageUrl:
          'https://images.unsplash.com/photo-1518152006812-edab29b069ac?q=80&w=2000&auto=format&fit=crop',
      reporterName: 'Jane Smith',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredNews = _selectedCategory == 'All'
        ? _allNews
        : _allNews.where((n) => n.category == _selectedCategory).toList();

    return Scaffold(
      body: CustomScrollView(
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
    );
  }
}
