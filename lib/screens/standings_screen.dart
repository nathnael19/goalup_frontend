import 'package:flutter/material.dart';

/// Standings Screen displaying tournament leaderboards
///
/// Features:
/// - Tournament selector tabs
/// - Standings table with team rankings
/// - Team statistics (played, won, drawn, lost, GD, points)
/// - Highlight top 3 positions
/// - Pull-to-refresh functionality
class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tournaments = [
    'Batch Cup 2024',
    '4th Year League',
    'Half Life-Cup',
    'GC Cup',
  ];

  // Mock standings data for each tournament
  final Map<String, List<Map<String, dynamic>>> _standingsData = {
    'Batch Cup 2024': [
      {
        'rank': 1,
        'team': 'Software Engineering',
        'played': 8,
        'won': 6,
        'drawn': 1,
        'lost': 1,
        'goalsFor': 18,
        'goalsAgainst': 7,
        'points': 19,
      },
      {
        'rank': 2,
        'team': 'Computer Science',
        'played': 8,
        'won': 5,
        'drawn': 2,
        'lost': 1,
        'goalsFor': 16,
        'goalsAgainst': 8,
        'points': 17,
      },
      {
        'rank': 3,
        'team': 'Information Systems',
        'played': 8,
        'won': 5,
        'drawn': 1,
        'lost': 2,
        'goalsFor': 14,
        'goalsAgainst': 9,
        'points': 16,
      },
      {
        'rank': 4,
        'team': 'Chemical Engineering',
        'played': 8,
        'won': 3,
        'drawn': 2,
        'lost': 3,
        'goalsFor': 11,
        'goalsAgainst': 12,
        'points': 11,
      },
      {
        'rank': 5,
        'team': 'Bio Engineering',
        'played': 8,
        'won': 2,
        'drawn': 3,
        'lost': 3,
        'goalsFor': 9,
        'goalsAgainst': 11,
        'points': 9,
      },
      {
        'rank': 6,
        'team': 'Mining Engineering',
        'played': 8,
        'won': 0,
        'drawn': 1,
        'lost': 7,
        'goalsFor': 4,
        'goalsAgainst': 25,
        'points': 1,
      },
    ],
    '4th Year League': [
      {
        'rank': 1,
        'team': 'Electrical Engineering',
        'played': 6,
        'won': 5,
        'drawn': 1,
        'lost': 0,
        'goalsFor': 15,
        'goalsAgainst': 3,
        'points': 16,
      },
      {
        'rank': 2,
        'team': 'Mechanical Engineering',
        'played': 6,
        'won': 4,
        'drawn': 0,
        'lost': 2,
        'goalsFor': 12,
        'goalsAgainst': 8,
        'points': 12,
      },
      {
        'rank': 3,
        'team': 'Civil Engineering',
        'played': 6,
        'won': 3,
        'drawn': 1,
        'lost': 2,
        'goalsFor': 10,
        'goalsAgainst': 9,
        'points': 10,
      },
      {
        'rank': 4,
        'team': 'Architecture',
        'played': 6,
        'won': 0,
        'drawn': 0,
        'lost': 6,
        'goalsFor': 2,
        'goalsAgainst': 19,
        'points': 0,
      },
    ],
    'Half Life-Cup': [
      {
        'rank': 1,
        'team': 'Urban Planning',
        'played': 5,
        'won': 4,
        'drawn': 1,
        'lost': 0,
        'goalsFor': 12,
        'goalsAgainst': 4,
        'points': 13,
      },
      {
        'rank': 2,
        'team': 'Geology',
        'played': 5,
        'won': 3,
        'drawn': 1,
        'lost': 1,
        'goalsFor': 9,
        'goalsAgainst': 6,
        'points': 10,
      },
      {
        'rank': 3,
        'team': 'Environmental Engineering',
        'played': 5,
        'won': 1,
        'drawn': 1,
        'lost': 3,
        'goalsFor': 5,
        'goalsAgainst': 10,
        'points': 4,
      },
    ],
    'GC Cup': [
      {
        'rank': 1,
        'team': 'Software Engineering',
        'played': 4,
        'won': 3,
        'drawn': 1,
        'lost': 0,
        'goalsFor': 10,
        'goalsAgainst': 3,
        'points': 10,
      },
      {
        'rank': 2,
        'team': 'Electrical Engineering',
        'played': 4,
        'won': 2,
        'drawn': 1,
        'lost': 1,
        'goalsFor': 7,
        'goalsAgainst': 5,
        'points': 7,
      },
      {
        'rank': 3,
        'team': 'Civil Engineering',
        'played': 4,
        'won': 0,
        'drawn': 0,
        'lost': 4,
        'goalsFor': 2,
        'goalsAgainst': 11,
        'points': 0,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tournaments.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Standings updated!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tournament tabs
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            tabs: _tournaments.map((tournament) {
              return Tab(text: tournament);
            }).toList(),
          ),
        ),
        // Standings table
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _tournaments.map((tournament) {
              final standings = _standingsData[tournament] ?? [];
              return RefreshIndicator(
                onRefresh: _handleRefresh,
                child: StandingsTable(standings: standings),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Standings Table Widget
class StandingsTable extends StatelessWidget {
  final List<Map<String, dynamic>> standings;

  const StandingsTable({super.key, required this.standings});

  @override
  Widget build(BuildContext context) {
    if (standings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No standings available',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '#',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Team',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                _buildHeaderCell(context, 'P'),
                _buildHeaderCell(context, 'W'),
                _buildHeaderCell(context, 'D'),
                _buildHeaderCell(context, 'L'),
                _buildHeaderCell(context, 'GD'),
                SizedBox(
                  width: 40,
                  child: Text(
                    'Pts',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table rows
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: standings.length,
            itemBuilder: (context, index) {
              final team = standings[index];
              final goalDifference = team['goalsFor'] - team['goalsAgainst'];
              final isTopThree = team['rank'] <= 3;

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                  color: isTopThree
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.1)
                      : null,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Rank with medal for top 3
                    SizedBox(
                      width: 40,
                      child: Row(
                        children: [
                          if (isTopThree)
                            Icon(
                              Icons.emoji_events,
                              size: 16,
                              color: team['rank'] == 1
                                  ? Colors.amber
                                  : team['rank'] == 2
                                  ? Colors.grey[400]
                                  : Colors.brown[300],
                            ),
                          const SizedBox(width: 4),
                          Text(
                            '${team['rank']}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: isTopThree
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Team name
                    Expanded(
                      flex: 3,
                      child: Text(
                        team['team'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isTopThree
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Stats
                    _buildStatCell(context, '${team['played']}'),
                    _buildStatCell(context, '${team['won']}'),
                    _buildStatCell(context, '${team['drawn']}'),
                    _buildStatCell(context, '${team['lost']}'),
                    _buildStatCell(
                      context,
                      goalDifference >= 0
                          ? '+$goalDifference'
                          : '$goalDifference',
                      color: goalDifference > 0
                          ? Colors.green
                          : goalDifference < 0
                          ? Colors.red
                          : null,
                    ),
                    // Points
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${team['points']}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Legend',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    _buildLegendItem(context, 'P', 'Played'),
                    _buildLegendItem(context, 'W', 'Won'),
                    _buildLegendItem(context, 'D', 'Drawn'),
                    _buildLegendItem(context, 'L', 'Lost'),
                    _buildLegendItem(context, 'GD', 'Goal Difference'),
                    _buildLegendItem(context, 'Pts', 'Points'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    return SizedBox(
      width: 35,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildStatCell(BuildContext context, String text, {Color? color}) {
    return SizedBox(
      width: 35,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: color ?? Colors.grey[700]),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String abbr, String full) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$abbr:',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          full,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
