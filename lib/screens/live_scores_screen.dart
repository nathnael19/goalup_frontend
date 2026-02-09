import 'package:flutter/material.dart';
import 'match_detail_screen.dart';

/// Live Scores Screen displaying ongoing and recent matches
///
/// Features:
/// - Scrollable list of live matches
/// - Match cards with team names, scores, and status
/// - Pull-to-refresh functionality
/// - Real-time score updates (placeholder for now)
class LiveScoresScreen extends StatefulWidget {
  const LiveScoresScreen({super.key});

  @override
  State<LiveScoresScreen> createState() => _LiveScoresScreenState();
}

class _LiveScoresScreenState extends State<LiveScoresScreen> {
  // Mock data for demonstration
  final List<Map<String, dynamic>> _matches = [
    {
      'homeTeam': 'Software Engineering',
      'awayTeam': 'Computer Science',
      'homeScore': 2,
      'awayScore': 1,
      'status': 'LIVE',
      'time': '67\'',
      'tournament': 'Batch Cup 2024',
    },
    {
      'homeTeam': 'Information Systems',
      'awayTeam': 'Electrical Engineering',
      'homeScore': 0,
      'awayScore': 0,
      'status': 'LIVE',
      'time': '23\'',
      'tournament': '4th Year League',
    },
    {
      'homeTeam': 'Civil Engineering',
      'awayTeam': 'Mechanical Engineering',
      'homeScore': 3,
      'awayScore': 2,
      'status': 'FT',
      'time': 'Full Time',
      'tournament': 'Half Life-Cup',
    },
    {
      'homeTeam': 'Architecture',
      'awayTeam': 'Urban Planning',
      'homeScore': 1,
      'awayScore': 1,
      'status': 'HT',
      'time': 'Half Time',
      'tournament': 'GC Cup',
    },
  ];

  Future<void> _handleRefresh() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scores updated!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: _matches.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MatchDetailScreen(match: _matches[index]),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: MatchCard(match: _matches[index]),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No live matches',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  final Map<String, dynamic> match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final isLive = match['status'] == 'LIVE';
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLive
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tournament & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      match['tournament'].toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Text(
                    match['status'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // Teams & Score
            Row(
              children: [
                // Home Team
                Expanded(
                  child: Column(
                    children: [
                      _buildTeamLogo(match['homeTeam']),
                      const SizedBox(height: 12),
                      Text(
                        match['homeTeam'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Score Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        '${match['homeScore']} - ${match['awayScore']}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isLive ? Colors.red : Colors.grey[400],
                          fontWeight: isLive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                // Away Team
                Expanded(
                  child: Column(
                    children: [
                      _buildTeamLogo(match['awayTeam']),
                      const SizedBox(height: 12),
                      Text(
                        match['awayTeam'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String name) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.substring(0, 1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
