import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match.dart' as model;
import '../models/team.dart';
import '../services/api_service.dart';
import 'team_detail_screen.dart';
import '../widgets/football_field.dart';
import '../utils/responsive.dart';

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
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40.w),
                bottomRight: Radius.circular(40.w),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTeamInfo(match.teamA, 'T1', isHome: true),
                    ),
                    _buildScoreInfo(match),
                    Expanded(
                      child: _buildTeamInfo(match.teamB, 'T2', isHome: false),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  match.venue ?? 'Main Stadium, ASTU',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Custom Tabs
          TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13.sp,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
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

  Widget _buildTeamInfo(
    Team? team,
    String fallbackName, {
    required bool isHome,
  }) {
    final teamName = team?.name ?? fallbackName;
    final logoUrl = ApiService.getImageFullUrl(team?.logoUrl);

    return GestureDetector(
      onTap: () {
        if (team != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamDetailScreen(team: team),
            ),
          );
        }
      },
      child: Column(
        children: [
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 2.w,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35.w),
              child: logoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: logoUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            teamName.isNotEmpty
                                ? teamName.substring(0, 1)
                                : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        teamName.isNotEmpty ? teamName.substring(0, 1) : '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            teamName,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreInfo(model.Match match) {
    final isLive = match.status == model.MatchStatus.live;
    return Column(
      children: [
        Text(
          '${match.scoreA} - ${match.scoreB}',
          style: TextStyle(
            fontSize: 48.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isLive ? Colors.red : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20.w),
          ),
          child: Text(
            isLive ? 'LIVE' : 'FINAL',
            style: TextStyle(
              color: isLive ? Colors.white : Colors.grey[400],
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineTab() {
    if (_memoizedEvents.isEmpty) {
      return Center(
        child: Text(
          'No events recorded',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      itemCount: _memoizedEvents.length,
      itemBuilder: (context, index) {
        final event = _memoizedEvents[index];
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
                    child: index == _memoizedEvents.length - 1
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
            textAlign: isHome ? TextAlign.right : TextAlign.left,
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
            .toList() ??
        [];
    final awayLineup =
        match.lineups
            ?.where((l) => l.teamId == match.teamBId && l.isStarting)
            .toList() ??
        [];

    final homeFormation = match.formationA ?? '4-3-3';
    final awayFormation = match.formationB ?? '4-3-3';

    if (homeLineup.isEmpty && awayLineup.isEmpty) {
      return Center(
        child: Text(
          'Lineups not available',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTeamLineupHeader(
            match.teamA?.name ?? 'Home',
            homeFormation,
            Theme.of(context).primaryColor,
          ),
          SizedBox(
            height: 450,
            child: FootballFieldWidget(
              lineup: homeLineup,
              formation: homeFormation,
              isHome: true,
              teamColor: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          _buildTeamLineupHeader(
            match.teamB?.name ?? 'Away',
            awayFormation,
            Colors.red,
          ),
          SizedBox(
            height: 450,
            child: FootballFieldWidget(
              lineup: awayLineup,
              formation: awayFormation,
              isHome: false,
              teamColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLineupHeader(
    String teamName,
    String formation,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                teamName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Text(
              formation,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
