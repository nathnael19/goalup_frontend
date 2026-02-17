import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/team.dart' as model;
import '../models/player.dart';
import '../services/api_service.dart';
import '../widgets/match_card.dart';

/// Detailed view for a specific team
class TeamDetailScreen extends StatefulWidget {
  final model.Team team;

  const TeamDetailScreen({super.key, required this.team});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late model.Team _detailedTeam;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _detailedTeam = widget.team;
    _fetchTeamDetail();
  }

  Future<void> _fetchTeamDetail() async {
    try {
      final apiService = ApiService();
      final detailedTeam = await apiService.getTeam(widget.team.id);
      if (mounted) {
        setState(() {
          _detailedTeam = detailedTeam;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _detailedTeam.name.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Column(
              children: [
                // Premium Team Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            width: 4,
                          ),
                        ),
                        child: Center(child: _buildTeamLogo(colorScheme)),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _detailedTeam.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_detailedTeam.stadium != null) ...[
                        Text(
                          _detailedTeam.stadium!.toUpperCase(),
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (_detailedTeam.tournament != null)
                        Text(
                          _detailedTeam.tournament!.name.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        )
                      else
                        Text(
                          (_detailedTeam.batch ?? 'N/A').toUpperCase(),
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildQuickStat('RANK', _getRank()),
                          _buildDivider(),
                          _buildQuickStat('POINTS', _getPoints()),
                          _buildDivider(),
                          _buildQuickStat('PLAYED', _getPlayed()),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tabs
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
                    Tab(text: 'ROSTER'),
                    Tab(text: 'STATS'),
                    Tab(text: 'MATCHES'),
                  ],
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRosterTab(),
                      _buildStatsTab(),
                      _buildMatchesTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTeamLogo(ColorScheme colorScheme) {
    final logoUrl = ApiService.getImageFullUrl(_detailedTeam.logoUrl);
    if (logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: CachedNetworkImage(
          imageUrl: logoUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const CircularProgressIndicator(strokeWidth: 2),
          errorWidget: (context, error, stackTrace) =>
              _buildLogoPlaceholder(colorScheme),
        ),
      );
    }
    return _buildLogoPlaceholder(colorScheme);
  }

  Widget _buildLogoPlaceholder(ColorScheme colorScheme) {
    return Text(
      _detailedTeam.name.isNotEmpty ? _detailedTeam.name[0] : 'T',
      style: TextStyle(
        color: colorScheme.primary,
        fontSize: 48,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, {bool isForm = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        if (isForm)
          Row(children: value.split(' ').map((v) => _buildFormDot(v)).toList())
        else
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
      ],
    );
  }

  Widget _buildFormDot(String result) {
    Color color = Colors.grey;
    if (result == 'W') color = Colors.greenAccent;
    if (result == 'L') color = Colors.redAccent;
    if (result == 'D') color = Colors.amberAccent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          result,
          style: const TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white.withValues(alpha: 0.05),
    );
  }

  Widget _buildRosterTab() {
    final roster = _detailedTeam.roster;
    if (roster == null || roster.isEmpty) {
      return const Center(child: Text('No roster information available'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (roster['goalkeepers']?.isNotEmpty ?? false)
          ..._buildPositionSection('GOALKEEPERS', roster['goalkeepers']!),
        if (roster['defenders']?.isNotEmpty ?? false)
          ..._buildPositionSection('DEFENDERS', roster['defenders']!),
        if (roster['midfielders']?.isNotEmpty ?? false)
          ..._buildPositionSection('MIDFIELDERS', roster['midfielders']!),
        if (roster['forwards']?.isNotEmpty ?? false)
          ..._buildPositionSection('FORWARDS', roster['forwards']!),
      ],
    );
  }

  List<Widget> _buildPositionSection(String title, List<Player> players) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Colors.grey[500],
            letterSpacing: 1.5,
          ),
        ),
      ),
      ...players.map((p) => _buildPlayerTile(p)),
    ];
  }

  Widget _buildPlayerTile(Player player) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        child: Text(
          player.jerseyNumber.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
      title: Text(
        player.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        player.position.toUpperCase(),
        style: TextStyle(color: Colors.grey[600], fontSize: 11),
      ),
      trailing: Text(
        player.goals > 0 ? '${player.goals} G' : '',
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.greenAccent,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getRank() {
    if (_detailedTeam.standings == null || _detailedTeam.standings!.isEmpty) {
      return '-';
    }
    return 'N/A';
  }

  String _getPoints() {
    if (_detailedTeam.standings == null || _detailedTeam.standings!.isEmpty) {
      return '0';
    }
    return _detailedTeam.standings!.first.points.toString();
  }

  String _getPlayed() {
    if (_detailedTeam.standings == null || _detailedTeam.standings!.isEmpty) {
      return '0';
    }
    return _detailedTeam.standings!.first.played.toString();
  }

  Widget _buildStatsTab() {
    final standing = _detailedTeam.standings?.isNotEmpty == true
        ? _detailedTeam.standings!.first
        : null;

    if (standing == null) {
      return const Center(child: Text('No stats available'));
    }

    final int played = standing.played;
    final int goalsFor = standing.goalsFor;
    final int goalsAgainst = standing.goalsAgainst;

    // Calculate clean sheets from matches
    int cleanSheets = 0;
    if (_detailedTeam.matches != null) {
      for (var m in _detailedTeam.matches!) {
        // Only count finished matches
        if (m.status.name == 'finished') {
          if (m.teamAId == _detailedTeam.id && m.scoreB == 0) {
            cleanSheets++;
          } else if (m.teamBId == _detailedTeam.id && m.scoreA == 0) {
            cleanSheets++;
          }
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildStatRow(
          'GOALS SCORED',
          goalsFor.toString(),
          played > 0 ? (goalsFor / (played * 3)).clamp(0, 1) : 0,
        ),
        _buildStatRow(
          'GOALS CONCEDED',
          goalsAgainst.toString(),
          played > 0 ? (goalsAgainst / (played * 3)).clamp(0, 1) : 0,
        ),
        _buildStatRow(
          'CLEAN SHEETS',
          cleanSheets.toString(),
          played > 0 ? (cleanSheets / played).clamp(0, 1) : 0,
        ),
        _buildStatRow(
          'WINS',
          standing.won.toString(),
          played > 0 ? (standing.won / played).clamp(0, 1) : 0,
        ),
        _buildStatRow(
          'DRAWS',
          standing.drawn.toString(),
          played > 0 ? (standing.drawn / played).clamp(0, 1) : 0,
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, double progress) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              Text(
                value,
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
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesTab() {
    if (_detailedTeam.matches != null && _detailedTeam.matches!.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _detailedTeam.matches!.length,
        itemBuilder: (context, index) {
          final match = _detailedTeam.matches![index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MatchCard(match: match),
          );
        },
      );
    } else {
      return Center(
        child: Text(
          'No matches found',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }
}
