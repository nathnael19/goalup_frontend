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

/// Match Card Widget displaying match information
class MatchCard extends StatelessWidget {
  final Map<String, dynamic> match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final isLive = match['status'] == 'LIVE';
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament name
            Row(
              children: [
                Icon(Icons.emoji_events, size: 16, color: colorScheme.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    match['tournament'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isLive ? Colors.red : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    match['status'],
                    style: TextStyle(
                      color: isLive ? Colors.white : Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Match details
            Row(
              children: [
                // Home team
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match['homeTeam'],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Score
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${match['homeScore']} - ${match['awayScore']}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                // Away team
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        match['awayTeam'],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Match time
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLive)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    match['time'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isLive ? Colors.red : Colors.grey[600],
                      fontWeight: isLive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
