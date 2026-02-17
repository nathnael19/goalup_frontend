import 'package:flutter/material.dart';
import '../models/match.dart' as model;
import '../utils/responsive.dart';

// Match Detail Components
import 'match_detail/match_billboard.dart';
import 'match_detail/match_timeline.dart';
import 'match_detail/match_lineups.dart';
import 'match_detail/match_stats.dart';

/// Detailed Match Screen showing timeline, stats, and lineups
class MatchDetailScreen extends StatefulWidget {
  final model.Match match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Map<String, dynamic>> _memoizedEvents;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _memoizedEvents = _generateEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _generateEvents() {
    final List<Map<String, dynamic>> events = [];
    final match = widget.match;

    // Add Goals
    if (match.goals != null) {
      for (var goal in match.goals!) {
        events.add({
          'min': goal.minute,
          'player': goal.player?.name ?? 'Unknown',
          'team': goal.teamId == match.teamAId ? 'home' : 'away',
          'type': 'goal',
          'detail': goal.isOwnGoal ? '(OG)' : '',
        });
      }
    }

    // Add Cards
    if (match.cards != null) {
      for (var card in match.cards!) {
        events.add({
          'min': card.minute,
          'player': card.player?.name ?? 'Unknown',
          'team': card.teamId == match.teamAId ? 'home' : 'away',
          'type': card.type == 'yellow' ? 'yellow_card' : 'red_card',
          'detail': '',
        });
      }
    }

    // Add Substitutions
    if (match.substitutions != null) {
      for (var sub in match.substitutions!) {
        events.add({
          'min': sub.minute,
          'player': '${sub.playerIn?.name} for ${sub.playerOut?.name}',
          'team': sub.teamId == match.teamAId ? 'home' : 'away',
          'type': 'sub',
          'detail': '',
        });
      }
    }

    events.sort((a, b) => (a['min'] as int).compareTo(b['min'] as int));
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final match = widget.match;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          (match.tournament?.name ?? 'MATCH DETAILS').toUpperCase(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, size: 20.sp),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          MatchBillboard(match: match),

          // Custom Tabs
          TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12.sp,
              letterSpacing: 1,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
            tabs: const [
              Tab(text: "TIMELINE"),
              Tab(text: "STATS"),
              Tab(text: "LINEUPS"),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                MatchTimeline(events: _memoizedEvents),
                const MatchStats(),
                MatchLineups(match: match),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
