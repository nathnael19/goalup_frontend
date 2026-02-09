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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isLive = widget.match['status'] == 'LIVE';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.match['tournament'] ?? 'Match Detail'),
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
      ),
      body: Column(
        children: [
          // Scoreboard Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                if (isLive)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTeamInfo(widget.match['homeTeam'], isHome: true),
                    _buildScore(widget.match),
                    _buildTeamInfo(widget.match['awayTeam'], isHome: false),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.match['time'] ?? 'Upcoming',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: colorScheme.primary,
              tabs: const [
                Tab(text: 'Timeline'),
                Tab(text: 'Stats'),
                Tab(text: 'Lineups'),
              ],
            ),
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
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Text(
            name.substring(0, 1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildScore(Map<String, dynamic> match) {
    if (match['status'] == 'upcoming') {
      return const Text(
        'Vs',
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Row(
      children: [
        Text(
          '${match['homeScore']}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '-',
            style: TextStyle(color: Colors.white38, fontSize: 32),
          ),
        ),
        Text(
          '${match['awayScore']}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineTab() {
    // Mock events
    final events = [
      {'min': '12\'', 'player': 'John Doe', 'team': 'home', 'type': 'goal'},
      {
        'min': '34\'',
        'player': 'Jane Smith',
        'team': 'away',
        'type': 'yellow_card',
      },
      {'min': '45+1\'', 'player': 'Half Time', 'team': 'none', 'type': 'info'},
      {'min': '67\'', 'player': 'Mike Johnson', 'team': 'home', 'type': 'goal'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final bool isHome = event['team'] == 'home';
        final bool isInfo = event['team'] == 'none';

        if (isInfo) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                event['player'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        return Row(
          mainAxisAlignment: isHome
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            if (!isHome) const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (isHome) ...[
                    Text(
                      event['min'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    _buildEventIcon(event['type'] as String),
                    const SizedBox(width: 8),
                  ],
                  Text(event['player'] as String),
                  if (!isHome) ...[
                    const SizedBox(width: 8),
                    _buildEventIcon(event['type'] as String),
                    const SizedBox(width: 8),
                    Text(
                      event['min'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
            if (isHome) const Spacer(),
          ],
        );
      },
    );
  }

  Widget _buildEventIcon(String type) {
    switch (type) {
      case 'goal':
        return const Icon(Icons.sports_soccer, size: 16, color: Colors.green);
      case 'yellow_card':
        return const Icon(Icons.rectangle, size: 16, color: Colors.amber);
      case 'red_card':
        return const Icon(Icons.rectangle, size: 16, color: Colors.red);
      default:
        return const Icon(Icons.info, size: 16);
    }
  }

  Widget _buildStatsTab() {
    final stats = [
      {'label': 'Possession', 'home': '54%', 'away': '46%', 'homeVal': 0.54},
      {'label': 'Shots', 'home': '12', 'away': '8', 'homeVal': 0.6},
      {'label': 'Shots on Target', 'home': '5', 'away': '3', 'homeVal': 0.62},
      {'label': 'Corners', 'home': '6', 'away': '4', 'homeVal': 0.6},
      {'label': 'Fouls', 'home': '10', 'away': '14', 'homeVal': 0.4},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stat['home'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    stat['label'] as String,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    stat['away'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: stat['homeVal'] as double,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLineupsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTeamLineup(widget.match['homeTeam'], [
            'Player A',
            'Player B',
            'Player C',
            'Player D',
          ]),
          const Divider(height: 40),
          _buildTeamLineup(widget.match['awayTeam'], [
            'Player X',
            'Player Y',
            'Player Z',
            'Player W',
          ]),
        ],
      ),
    );
  }

  Widget _buildTeamLineup(String team, List<String> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$team Lineup',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...players.map(
          (p) => ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(p),
            trailing: const Text('FW'),
          ),
        ),
      ],
    );
  }
}
