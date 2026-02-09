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
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: _tournaments.map((tournament) {
            return Tab(text: tournament.toUpperCase());
          }).toList(),
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
    final colorScheme = Theme.of(context).colorScheme;

    if (standings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined, size: 80, color: Colors.grey[800]),
            const SizedBox(height: 16),
            Text(
              'No standings available',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    '#',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      color: Colors.grey[500],
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'TEAM',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      color: Colors.grey[500],
                      letterSpacing: 1,
                    ),
                  ),
                ),
                _buildHeaderCell('P'),
                _buildHeaderCell('W'),
                _buildHeaderCell('D'),
                _buildHeaderCell('L'),
                _buildHeaderCell('GD'),
                SizedBox(
                  width: 32,
                  child: Text(
                    'PTS',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      color: colorScheme.primary,
                      letterSpacing: 1,
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
              final bool isLast = index == standings.length - 1;

              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer.withValues(
                    alpha: index % 2 == 0 ? 0.3 : 0.6,
                  ),
                  borderRadius: isLast
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        )
                      : null,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Rank
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${team['rank']}',
                        style: TextStyle(
                          fontWeight: isTopThree
                              ? FontWeight.w900
                              : FontWeight.bold,
                          color: team['rank'] == 1
                              ? Colors.amber
                              : team['rank'] == 2
                              ? Colors.grey[400]
                              : team['rank'] == 3
                              ? Colors.brown[300]
                              : Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ),
                    // Team name
                    Expanded(
                      flex: 3,
                      child: Text(
                        team['team'],
                        style: TextStyle(
                          fontWeight: isTopThree
                              ? FontWeight.w900
                              : FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Stats
                    _buildStatCell('${team['played']}'),
                    _buildStatCell('${team['won']}'),
                    _buildStatCell('${team['drawn']}'),
                    _buildStatCell('${team['lost']}'),
                    _buildStatCell(
                      goalDifference >= 0
                          ? '+$goalDifference'
                          : '$goalDifference',
                      color: goalDifference > 0
                          ? Colors.greenAccent
                          : goalDifference < 0
                          ? Colors.redAccent
                          : Colors.grey[600],
                    ),
                    // Points
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${team['points']}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: isTopThree
                              ? colorScheme.primary
                              : Colors.white,
                          fontSize: 13,
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
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'LEGEND',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildLegendItem('P', 'Played'),
                    _buildLegendItem('W', 'Won'),
                    _buildLegendItem('D', 'Drawn'),
                    _buildLegendItem('L', 'Lost'),
                    _buildLegendItem('GD', 'Goal Difference'),
                    _buildLegendItem('PTS', 'Points'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return SizedBox(
      width: 30,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 10,
          color: Colors.grey[500],
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildStatCell(String text, {Color? color}) {
    return SizedBox(
      width: 30,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color ?? Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegendItem(String abbr, String full) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$abbr ',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
        Text(
          full,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
