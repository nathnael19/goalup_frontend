import 'package:flutter/material.dart';
import '../models/match.dart' as model;

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final match = widget.match;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          (match.tournament?.name ?? 'MATCH DETAILS').toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Premium Scoreboard Billboard
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTeamInfo(
                        match.teamA?.name ?? 'T1',
                        isHome: true,
                      ),
                    ),
                    _buildScoreInfo(match),
                    Expanded(
                      child: _buildTeamInfo(
                        match.teamB?.name ?? 'T2',
                        isHome: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  match.venue ?? 'Main Stadium, ASTU',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Custom Tabs
          TabBar(
            controller: _tabController,
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
            tabs: const [
              Tab(text: 'TIMELINE'),
              Tab(text: 'STATS'),
              Tab(text: 'LINEUPS'),
            ],
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTimelineTab(),
                _buildStatsTab(),
                _buildLineupsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(String teamName, {required bool isHome}) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 2),
          ),
          child: Center(
            child: Text(
              teamName.substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          teamName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildScoreInfo(model.Match match) {
    final isLive = match.status == model.MatchStatus.live;
    return Column(
      children: [
        Text(
          '${match.scoreA} - ${match.scoreB}',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isLive ? Colors.red : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isLive ? '67\'' : 'FINAL',
            style: TextStyle(
              color: isLive ? Colors.white : Colors.grey[400],
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineTab() {
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

    // Add Substitutions (Optional, depending on UI preference)
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

    // Sort by minute
    events.sort((a, b) => (a['min'] as int).compareTo(b['min'] as int));

    if (events.isEmpty) {
      return Center(
        child: Text(
          'No events recorded',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final bool isHome = event['team'] == 'home';

        return IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: isHome
                    ? _buildEventContent(event, isHome: true)
                    : const SizedBox(),
              ),
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isHome
                          ? Theme.of(context).colorScheme.primary
                          : (event['team'] == 'away'
                                ? Colors.grey[700]
                                : Colors.transparent),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: index == events.length - 1
                        ? const SizedBox()
                        : VerticalDivider(
                            width: 2,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                  ),
                ],
              ),
              Expanded(
                child: !isHome
                    ? _buildEventContent(event, isHome: false)
                    : const SizedBox(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventContent(
    Map<String, dynamic> event, {
    required bool isHome,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: isHome ? 0 : 16,
        right: isHome ? 16 : 0,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: isHome
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isHome
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!isHome) _buildEventIcon(event['type'] as String),
              if (!isHome) const SizedBox(width: 8),
              Text(
                "${event['min']}'",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              if (isHome) const SizedBox(width: 8),
              if (isHome) _buildEventIcon(event['type'] as String),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "${event['player']} ${event['detail']}",
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventIcon(String type) {
    switch (type) {
      case 'goal':
        return const Icon(
          Icons.sports_soccer,
          size: 16,
          color: Colors.greenAccent,
        );
      case 'yellow_card':
        return Container(
          width: 10,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case 'red_card':
        return Container(
          width: 10,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case 'sub':
        return const Icon(Icons.sync_alt, size: 16, color: Colors.blueAccent);
      default:
        return const Icon(Icons.info_outline, size: 16);
    }
  }

  Widget _buildStatsTab() {
    // Stats are not yet available from the backend
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'Match stats not available',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildLineupsTab() {
    final match = widget.match;
    final homeLineup =
        match.lineups
            ?.where((l) => l.teamId == match.teamAId && l.isStarting)
            .map((l) => l.player?.name ?? 'Unknown') // Ideally include position
            .toList() ??
        [];

    final awayLineup =
        match.lineups
            ?.where((l) => l.teamId == match.teamBId && l.isStarting)
            .map((l) => l.player?.name ?? 'Unknown')
            .toList() ??
        [];

    if (homeLineup.isEmpty && awayLineup.isEmpty) {
      return Center(
        child: Text(
          'Lineups not available',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTeamLineup(widget.match.teamA?.name ?? 'Home', homeLineup),
          const SizedBox(height: 32),
          _buildTeamLineup(widget.match.teamB?.name ?? 'Away', awayLineup),
        ],
      ),
    );
  }

  Widget _buildTeamLineup(String team, List<String> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              team.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...players.map(
          (p) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              child: Text(
                p.isNotEmpty ? p[0] : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              p,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
