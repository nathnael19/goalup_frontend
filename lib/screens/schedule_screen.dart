import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/match_cubit.dart';
import '../models/match.dart' as model;
import '../widgets/match_card.dart';
import 'match_detail_screen.dart';
import '../utils/responsive.dart';

// Schedule Components
import 'schedule/calendar_strip.dart';
import 'schedule/league_section.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  final Set<String> _collapsedTournaments = {};
  bool _hideAll = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
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
      final competitionName =
          match.tournament?.competition?.name ??
          match.tournament?.name ??
          'Other';
      if (!grouped.containsKey(competitionName)) {
        grouped[competitionName] = [];
      }
      grouped[competitionName]!.add(match);
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
            CalendarStrip(
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() => _selectedDate = date);
              },
            ),
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

  Widget _buildLeagueList(List<model.Match> allMatches) {
    final filteredMatches = _getFilteredMatches(allMatches);
    final groupedMatches = _getGroupedMatches(filteredMatches);
    final liveMatches = context.read<MatchCubit>().getLiveMatches(allMatches);

    if (filteredMatches.isEmpty && liveMatches.isEmpty) {
      return Expanded(child: _buildEmptyState());
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          children: [
            if (liveMatches.isNotEmpty) ...[
              _buildLiveMatchesSection(liveMatches),
              SizedBox(height: 24.h),
              if (filteredMatches.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    "SCHEDULED",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              SizedBox(height: 12.h),
            ],

            ...groupedMatches.entries.map((entry) {
              return LeagueSection(
                name: entry.key,
                matches: entry.value,
                isCollapsed: _collapsedTournaments.contains(entry.key),
                onToggle: () => _toggleTournament(entry.key),
              );
            }),

            if (filteredMatches.isEmpty && liveMatches.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(32.w),
                child: const Center(
                  child: Text(
                    "No scheduled matches for this date",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

            SizedBox(height: 24.h),
            if (filteredMatches.isNotEmpty) _buildHideAllToggle(groupedMatches),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMatchesSection(List<model.Match> liveMatches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 4),
            const Icon(Icons.circle, color: Colors.red, size: 10),
            const SizedBox(width: 8),
            Text(
              "LIVE NOW",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16.sp,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
              ),
              child: Text(
                liveMatches.length.toString(),
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ...liveMatches.map(
          (match) => GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchDetailScreen(match: match),
                ),
              );
            },
            child: MatchCard(match: match),
          ),
        ),
      ],
    );
  }

  Widget _buildHideAllToggle(Map<String, List<model.Match>> grouped) {
    return Center(
      child: ActionChip(
        onPressed: () => _toggleHideAll(grouped),
        backgroundColor: const Color(0xFF1E1E1E),
        labelPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.w),
        ),
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
            SizedBox(width: 8.w),
            Icon(
              _hideAll ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: Colors.white,
              size: 20.sp,
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
          Icon(Icons.event_busy_outlined, size: 80.sp, color: Colors.grey[800]),
          SizedBox(height: 16.h),
          Text(
            'NO MATCHES FOUND FOR THIS DATE',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11.sp,
              letterSpacing: 1,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
