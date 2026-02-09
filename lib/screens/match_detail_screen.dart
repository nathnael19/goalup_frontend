import 'package:flutter/material.dart';

/// Detailed Match Screen showing timeline, stats, and lineups
class MatchDetailScreen extends StatefulWidget {
  final Map<String, dynamic> match;

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
    final bool isLive = widget.match['status'] == 'LIVE';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          (widget.match['tournament'] as String).toUpperCase(),
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
                if (isLive)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'LIVE • 67\'',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTeamInfo(
                        widget.match['homeTeam'],
                        isHome: true,
                      ),
                    ),
                    _buildScore(widget.match),
                    Expanded(
                      child: _buildTeamInfo(
                        widget.match['awayTeam'],
                        isHome: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  widget.match['venue'] ?? 'Main Stadium, ASTU',
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

  Widget _buildTeamInfo(String name, {required bool isHome}) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              name.substring(0, 1),
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
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildScore(Map<String, dynamic> match) {
    if (match['status'] == 'upcoming') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'VS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white24,
          ),
        ),
      );
    }
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${match['homeScore']}',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                ':',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white24,
                ),
              ),
            ),
            Text(
              '${match['awayScore']}',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineTab() {
    final events = [
      {'min': '12\'', 'player': 'John Doe', 'team': 'home', 'type': 'goal'},
      {
        'min': '34\'',
        'player': 'Jane Smith',
        'team': 'away',
        'type': 'yellow_card',
      },
      {'min': 'HT', 'player': 'HALF TIME', 'team': 'none', 'type': 'info'},
      {'min': '67\'', 'player': 'Mike Johnson', 'team': 'home', 'type': 'goal'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final bool isHome = event['team'] == 'home';
        final bool isInfo = event['team'] == 'none';

        if (isInfo) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              children: [
                const Expanded(child: Divider(endIndent: 16)),
                Text(
                  event['player'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.grey[600],
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
                const Expanded(child: Divider(indent: 16)),
              ],
            ),
          );
        }

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
                event['min'] as String,
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
            event['player'] as String,
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
      default:
        return const Icon(Icons.info_outline, size: 16);
    }
  }

  Widget _buildStatsTab() {
    final stats = [
      {'label': 'POSSESSION', 'home': '54%', 'away': '46%', 'homeVal': 0.54},
      {'label': 'SHOTS', 'home': '12', 'away': '8', 'homeVal': 0.6},
      {'label': 'ON TARGET', 'home': '5', 'away': '3', 'homeVal': 0.62},
      {'label': 'CORNERS', 'home': '6', 'away': '4', 'homeVal': 0.6},
      {'label': 'FOULS', 'home': '10', 'away': '14', 'homeVal': 0.4},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stat['home'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    stat['label'] as String,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    stat['away'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: stat['homeVal'] as double,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLineupsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTeamLineup(widget.match['homeTeam'], [
            'J. Doe (GK)',
            'M. Smith',
            'A. Johnson',
            'K. Williams',
          ]),
          const SizedBox(height: 32),
          _buildTeamLineup(widget.match['awayTeam'], [
            'L. Brown (GK)',
            'P. Davis',
            'R. Miller',
            'S. Wilson',
          ]),
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
                p[0],
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
            trailing: Text(
              p.contains('(GK)') ? 'GK' : 'FW',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
