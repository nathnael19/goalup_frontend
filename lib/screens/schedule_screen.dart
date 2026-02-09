import 'package:flutter/material.dart';

/// Match Schedule Screen displaying upcoming and past matches
///
/// Features:
/// - List of matches grouped by date
/// - Tournament filter dropdown
/// - Match cards with date, time, and teams
/// - Pull-to-refresh functionality
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _selectedTournament = 'All Tournaments';

  final List<String> _tournaments = [
    'All Tournaments',
    'Batch Cup 2024',
    '4th Year League',
    'Half Life-Cup',
    'GC Cup',
  ];

  // Mock data for demonstration
  final List<Map<String, dynamic>> _allMatches = [
    {
      'homeTeam': 'Software Engineering',
      'awayTeam': 'Computer Science',
      'date': '2024-02-10',
      'time': '14:00',
      'tournament': 'Batch Cup 2024',
      'venue': 'Main Stadium',
      'status': 'upcoming',
    },
    {
      'homeTeam': 'Information Systems',
      'awayTeam': 'Electrical Engineering',
      'date': '2024-02-10',
      'time': '16:00',
      'tournament': '4th Year League',
      'venue': 'Training Ground',
      'status': 'upcoming',
    },
    {
      'homeTeam': 'Civil Engineering',
      'awayTeam': 'Mechanical Engineering',
      'date': '2024-02-11',
      'time': '15:00',
      'tournament': 'Half Life-Cup',
      'venue': 'Main Stadium',
      'status': 'upcoming',
    },
    {
      'homeTeam': 'Architecture',
      'awayTeam': 'Urban Planning',
      'date': '2024-02-11',
      'time': '17:00',
      'tournament': 'GC Cup',
      'venue': 'Training Ground',
      'status': 'upcoming',
    },
    {
      'homeTeam': 'Chemical Engineering',
      'awayTeam': 'Bio Engineering',
      'date': '2024-02-09',
      'time': '14:00',
      'tournament': 'Batch Cup 2024',
      'venue': 'Main Stadium',
      'status': 'finished',
      'homeScore': 2,
      'awayScore': 1,
    },
    {
      'homeTeam': 'Mining Engineering',
      'awayTeam': 'Geology',
      'date': '2024-02-09',
      'time': '16:00',
      'tournament': '4th Year League',
      'venue': 'Training Ground',
      'status': 'finished',
      'homeScore': 0,
      'awayScore': 3,
    },
  ];

  List<Map<String, dynamic>> get _filteredMatches {
    if (_selectedTournament == 'All Tournaments') {
      return _allMatches;
    }
    return _allMatches
        .where((match) => match['tournament'] == _selectedTournament)
        .toList();
  }

  Map<String, List<Map<String, dynamic>>> get _groupedMatches {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var match in _filteredMatches) {
      final date = match['date'] as String;
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(match);
    }
    // Sort dates in descending order (most recent first)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
  }

  Future<void> _handleRefresh() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule updated!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final matchDate = DateTime(date.year, date.month, date.day);

    if (matchDate == today) {
      return 'Today';
    } else if (matchDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (matchDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tournament filter
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Row(
            children: [
              Icon(
                Icons.filter_list,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedTournament,
                  isExpanded: true,
                  underline: Container(),
                  items: _tournaments.map((tournament) {
                    return DropdownMenuItem(
                      value: tournament,
                      child: Text(tournament),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTournament = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        // Matches list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: _filteredMatches.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _groupedMatches.length,
                    itemBuilder: (context, index) {
                      final date = _groupedMatches.keys.elementAt(index);
                      final matches = _groupedMatches[date]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: EdgeInsets.only(
                              left: 4,
                              bottom: 12,
                              top: index == 0 ? 0 : 16,
                            ),
                            child: Text(
                              _formatDate(date),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ),
                          // Matches for this date
                          ...matches.map(
                            (match) => ScheduleMatchCard(match: match),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No matches scheduled',
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

/// Schedule Match Card Widget
class ScheduleMatchCard extends StatelessWidget {
  final Map<String, dynamic> match;

  const ScheduleMatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final isFinished = match['status'] == 'finished';
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament and time
            Row(
              children: [
                Icon(Icons.emoji_events, size: 14, color: colorScheme.primary),
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
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  match['time'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Teams
            Row(
              children: [
                Expanded(
                  child: Text(
                    match['homeTeam'],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isFinished)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${match['homeScore']} - ${match['awayScore']}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Text(
                    'vs',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                Expanded(
                  child: Text(
                    match['awayTeam'],
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Venue
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  match['venue'],
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
