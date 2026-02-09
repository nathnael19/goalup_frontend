import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/match_cubit.dart';
import '../models/match.dart' as model;
import 'match_detail_screen.dart';

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

  // Removed mock data as it's no longer used.

  List<model.Match> _getFilteredMatches(List<model.Match> allMatches) {
    if (_selectedTournament == 'All Tournaments') {
      return allMatches;
    }
    return allMatches
        .where((match) => match.tournament?.name == _selectedTournament)
        .toList();
  }

  Map<String, List<model.Match>> _getGroupedMatches(
    List<model.Match> filteredMatches,
  ) {
    final Map<String, List<model.Match>> grouped = {};
    for (var match in filteredMatches) {
      final date = match.startTime.toIso8601String().split('T')[0];
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
    await context.read<MatchCubit>().fetchMatches();
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
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<MatchCubit, MatchState>(
      builder: (context, state) {
        // Collect all tournament names for the filter
        final List<String> tournaments = ['All Tournaments'];
        if (state is MatchLoaded) {
          final set = state.matches
              .map((m) => m.tournament?.name)
              .whereType<String>()
              .toSet();
          tournaments.addAll(set);
        }

        return Column(
          children: [
            // Tournament filter - Modern chip-style scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: tournaments.map((tournament) {
                  final isSelected = _selectedTournament == tournament;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        tournament.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: isSelected ? Colors.white : Colors.grey[400],
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTournament = tournament;
                        });
                      },
                      backgroundColor: colorScheme.surfaceContainer,
                      selectedColor: colorScheme.primary,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (state is MatchLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (state is MatchLoaded)
              _buildMatchesList(state.matches, colorScheme)
            else if (state is MatchError)
              Expanded(child: Center(child: Text(state.message)))
            else
              const SizedBox(),
          ],
        );
      },
    );
  }

  Widget _buildMatchesList(
    List<model.Match> allMatches,
    ColorScheme colorScheme,
  ) {
    final filteredMatches = _getFilteredMatches(allMatches);
    final groupedMatches = _getGroupedMatches(filteredMatches);

    if (filteredMatches.isEmpty) {
      return Expanded(child: _buildEmptyState());
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: groupedMatches.length,
          itemBuilder: (context, index) {
            final date = groupedMatches.keys.elementAt(index);
            final matches = groupedMatches[date]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date header
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 24, 0, 16),
                  child: Row(
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
                      Text(
                        _formatDate(date).toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          color: Colors.grey[500],
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Matches for this date
                ...matches.map(
                  (match) => InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchDetailScreen(match: match),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: ScheduleMatchCard(match: match),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text(
            'NO MATCHES FOUND',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 1,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Schedule Match Card Widget
class ScheduleMatchCard extends StatelessWidget {
  final model.Match match;

  const ScheduleMatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final isFinished = match.status == model.MatchStatus.finished;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 12,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (match.tournament?.name ?? 'TOURNAMENT').toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${match.startTime.hour}:${match.startTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  match.teamA?.name ?? 'Home',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              if (isFinished)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${match.scoreA} - ${match.scoreB}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                const Text(
                  'VS',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    color: Colors.white12,
                  ),
                ),
              Expanded(
                child: Text(
                  match.teamB?.name ?? 'Away',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 12,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                match.venue ?? 'Main Stadium, ASTU',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
