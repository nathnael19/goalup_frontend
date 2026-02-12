import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubits/match_cubit.dart';
import '../models/match.dart' as model;
import 'match_detail_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  final Set<String> _collapsedTournaments = {};
  bool _hideAll = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        const itemWidth = 110.0;
        final screenWidth = MediaQuery.of(context).size.width;
        // Today is at index 7
        final targetOffset =
            (7 * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await context.read<MatchCubit>().fetchMatches();
  }

  List<model.Match> _getFilteredMatches(List<model.Match> allMatches) {
    return allMatches.where((match) {
      final matchDate = DateTime(
        match.startTime.year,
        match.startTime.month,
        match.startTime.day,
      );
      return matchDate.isAtSameMomentAs(_selectedDate);
    }).toList();
  }

  Map<String, List<model.Match>> _getGroupedMatches(
    List<model.Match> filteredMatches,
  ) {
    final Map<String, List<model.Match>> grouped = {};
    for (var match in filteredMatches) {
      final tournamentName = match.tournament?.name ?? 'Other';
      if (!grouped.containsKey(tournamentName)) {
        grouped[tournamentName] = [];
      }
      grouped[tournamentName]!.add(match);
    }
    return grouped;
  }

  void _toggleTournament(String name) {
    setState(() {
      if (_collapsedTournaments.contains(name)) {
        _collapsedTournaments.remove(name);
      } else {
        _collapsedTournaments.add(name);
      }
    });
  }

  void _toggleHideAll(Map<String, List<model.Match>> grouped) {
    setState(() {
      _hideAll = !_hideAll;
      if (_hideAll) {
        _collapsedTournaments.addAll(grouped.keys);
      } else {
        _collapsedTournaments.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchCubit, MatchState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildDateSelector(),
            if (state is MatchLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (state is MatchLoaded)
              _buildLeagueList(state.matches)
            else if (state is MatchError)
              Expanded(child: Center(child: Text(state.message)))
            else
              const SizedBox(),
          ],
        );
      },
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 15,
        itemBuilder: (context, index) {
          final date = today.add(Duration(days: index - 7));
          final isSelected = date.isAtSameMomentAs(_selectedDate);
          final isToday = date.isAtSameMomentAs(today);

          String label;
          if (isToday) {
            label = 'Today';
          } else if (date.isAtSameMomentAs(
            today.subtract(const Duration(days: 1)),
          )) {
            label = 'Yesterday';
          } else if (date.isAtSameMomentAs(
            today.add(const Duration(days: 1)),
          )) {
            label = 'Tomorrow';
          } else {
            label = DateFormat('EEE d MMM').format(date);
          }

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 110,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? Colors.green : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isToday
                          ? Colors.green[300]
                          : Colors.grey[500],
                      fontWeight: isSelected || isToday
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  if (isToday && !isSelected)
                    Positioned(
                      top: 4,
                      right: 12,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeagueList(List<model.Match> allMatches) {
    final filteredMatches = _getFilteredMatches(allMatches);
    final groupedMatches = _getGroupedMatches(filteredMatches);

    if (filteredMatches.isEmpty) {
      return Expanded(child: _buildEmptyState());
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          children: [
            // List of Leagues
            ...groupedMatches.entries.map((entry) {
              return _buildLeagueSection(entry.key, entry.value);
            }),

            const SizedBox(height: 24),
            _buildHideAllToggle(groupedMatches),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueSection(String name, List<model.Match> matches) {
    final isCollapsed = _collapsedTournaments.contains(name);

    return Column(
      children: [
        GestureDetector(
          onTap: () => _toggleTournament(name),
          child: _buildCollapseHeader(
            name,
            matches.length.toString(),
            isCollapsed,
            leading: _buildFlagPlaceholder(),
          ),
        ),
        if (!isCollapsed) ...matches.map((match) => _buildMatchItem(match)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCollapseHeader(
    String title,
    String count,
    bool isCollapsed, {
    Widget? leading,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading, const SizedBox(width: 12)],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          if (count.isNotEmpty)
            Text(
              count,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          const SizedBox(width: 8),
          Icon(
            isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
            color: Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchItem(model.Match match) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailScreen(match: match),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: Row(
          children: [
            // Home Team Name
            Expanded(
              child: Text(
                match.teamA?.name ?? '',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Home Team Logo
            _buildTeamLogo(match.teamA?.name ?? 'A'),
            const SizedBox(width: 12),
            // Time / Score
            Column(
              children: [
                Text(
                  match.status == model.MatchStatus.finished
                      ? '${match.scoreA} - ${match.scoreB}'
                      : DateFormat('HH:mm').format(match.startTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (match.status == model.MatchStatus.live)
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Away Team Logo
            _buildTeamLogo(match.teamB?.name ?? 'B'),
            const SizedBox(width: 12),
            // Away Team Name
            Expanded(
              child: Text(
                match.teamB?.name ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String name) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFlagPlaceholder() {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildHideAllToggle(Map<String, List<model.Match>> grouped) {
    return Center(
      child: ActionChip(
        onPressed: () => _toggleHideAll(grouped),
        backgroundColor: const Color(0xFF1E1E1E),
        labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _hideAll ? 'Show all' : 'Hide all',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _hideAll ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: Colors.white,
              size: 20,
            ),
          ],
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
            'NO MATCHES FOUND FOR THIS DATE',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
