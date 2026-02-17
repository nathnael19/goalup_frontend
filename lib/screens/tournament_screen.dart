import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/standings_cubit.dart';
import '../cubits/match_cubit.dart';
import '../cubits/player_stats_cubit.dart';
import '../services/api_service.dart';
import '../models/match.dart' as match_model;
import '../models/player.dart';
import '../models/standing.dart' as standing_model;
import '../widgets/match_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'standings_screen.dart'; // For StandingsTable

class TournamentScreen extends StatefulWidget {
  final String? competitionId;

  const TournamentScreen({super.key, this.competitionId});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  String? _selectedTournamentId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Pre-process Data to keep build method clean
  Map<String, dynamic>? _getTournamentData(StandingsLoaded state) {
    if (state.tournaments.isEmpty) return null;

    final String? targetCompetitionId = widget.competitionId;
    List<dynamic> seasonTournaments;

    if (targetCompetitionId != null) {
      seasonTournaments = state.tournaments.where((t) {
        final tComp = t['tournament']['competition'];
        return tComp != null && tComp['id'] == targetCompetitionId;
      }).toList();
    } else {
      final firstComp = state.tournaments[0]['tournament']['competition'];
      final firstCompId = firstComp?['id'];
      seasonTournaments = state.tournaments.where((t) {
        final tComp = t['tournament']['competition'];
        return tComp != null && tComp['id'] == firstCompId;
      }).toList();
    }

    if (seasonTournaments.isEmpty) {
      seasonTournaments = List.from(state.tournaments);
    }

    seasonTournaments.sort((a, b) {
      int yearA = a['tournament']['year'] ?? 0;
      int yearB = b['tournament']['year'] ?? 0;
      return yearB.compareTo(yearA);
    });

    final selectedTournamentData = _selectedTournamentId == null
        ? seasonTournaments.first
        : seasonTournaments.firstWhere(
            (t) => t['tournament']['id'] == _selectedTournamentId,
            orElse: () => seasonTournaments.first,
          );

    final selectedTournament = selectedTournamentData['tournament'];

    return {
      'seasons': seasonTournaments,
      'selected': selectedTournament,
      'competitionName':
          selectedTournament['competition']?['name'] ?? 'Tournament',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<StandingsCubit, StandingsState>(
          listener: (context, state) {
            if (state is StandingsLoaded && _selectedTournamentId == null) {
              final data = _getTournamentData(state);
              if (data != null) {
                setState(() {
                  _selectedTournamentId = data['selected']['id'];
                });
              }
            }
          },
        ),
      ],
      child: Scaffold(
        body: BlocBuilder<StandingsCubit, StandingsState>(
          builder: (context, state) {
            return NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 120,
                    pinned: true,
                    stretch: true,
                    backgroundColor: colorScheme.surface,
                    flexibleSpace: FlexibleSpaceBar(
                      background: RepaintBoundary(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Tournament Header Gradient
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    colorScheme.primary.withValues(alpha: 0.8),
                                    colorScheme.surface,
                                  ],
                                ),
                              ),
                            ),
                            if (state is StandingsLoaded) ...[
                              Builder(
                                builder: (context) {
                                  final data = _getTournamentData(state);
                                  if (data == null) {
                                    return const SizedBox.shrink();
                                  }

                                  final List<dynamic> seasonTournaments =
                                      data['seasons'];
                                  final selectedTournament = data['selected'];
                                  final String competitionName =
                                      data['competitionName'];

                                  final logoUrl = ApiService.getImageFullUrl(
                                    selectedTournament['image_url']
                                            ?.toString() ??
                                        selectedTournament['competition']?['image_url']
                                            ?.toString(),
                                  );

                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      80,
                                      20,
                                      20,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            // Tournament Logo - Optimized with CachedNetworkImage
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: logoUrl.isNotEmpty
                                                  ? CachedNetworkImage(
                                                      imageUrl: logoUrl,
                                                      fit: BoxFit.contain,
                                                      placeholder: (context, url) =>
                                                          const CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                      errorWidget: (_, _, _) =>
                                                          const Icon(
                                                            Icons.emoji_events,
                                                            color: Colors.black,
                                                            size: 30,
                                                          ),
                                                    )
                                                  : const Icon(
                                                      Icons.emoji_events,
                                                      color: Colors.black,
                                                      size: 30,
                                                    ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    competitionName,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.white,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    'ASTU',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[400],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(
                                                  alpha: 0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value:
                                                      selectedTournament['id'],
                                                  dropdownColor: const Color(
                                                    0xFF222222,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  items: seasonTournaments
                                                      .map<
                                                        DropdownMenuItem<String>
                                                      >((t) {
                                                        final tour =
                                                            t['tournament'];
                                                        final y =
                                                            tour['year'] ??
                                                            2025;
                                                        return DropdownMenuItem<
                                                          String
                                                        >(
                                                          value: tour['id'],
                                                          child: Text(
                                                            '$y/${y + 1}',
                                                          ),
                                                        );
                                                      })
                                                      .toList(),
                                                  onChanged: (String? newValue) {
                                                    if (newValue != null) {
                                                      setState(
                                                        () =>
                                                            _selectedTournamentId =
                                                                newValue,
                                                      );
                                                    }
                                                  },
                                                  isDense: true,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorColor: colorScheme.primary,
                        indicatorWeight: 3,
                        dividerColor: Colors.transparent,
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
                          Tab(text: 'STANDINGS'),
                          Tab(text: 'FIXTURES'),
                          Tab(text: 'PLAYER STATS'),
                          Tab(text: 'TEAM STATS'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  RepaintBoundary(
                    child: StandingsTab(tournamentId: _selectedTournamentId),
                  ),
                  RepaintBoundary(
                    child: FixturesTab(tournamentId: _selectedTournamentId),
                  ),
                  RepaintBoundary(
                    child: PlayerStatsTab(tournamentId: _selectedTournamentId),
                  ),
                  RepaintBoundary(
                    child: TeamStatsTab(tournamentId: _selectedTournamentId),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(
        context,
      ).colorScheme.surface, // Background color for the tab bar
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class StandingsTab extends StatelessWidget {
  final String? tournamentId;
  const StandingsTab({super.key, this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StandingsCubit, StandingsState>(
      builder: (context, state) {
        if (state is StandingsLoaded && state.tournaments.isNotEmpty) {
          var tournamentData = state.tournaments.firstWhere(
            (t) => t['tournament']['id'] == tournamentId,
            orElse: () => state.tournaments[0],
          );

          final List<dynamic> teamsJson = tournamentData['teams'];
          final List<standing_model.Standing> standings = teamsJson
              .map((s) => standing_model.Standing.fromJson(s))
              .toList();
          return StandingsTable(standings: standings);
        }
        if (state is StandingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Center(child: Text('No standings data'));
      },
    );
  }
}

class FixturesTab extends StatelessWidget {
  final String? tournamentId;
  const FixturesTab({super.key, this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchCubit, MatchState>(
      builder: (context, state) {
        if (state is MatchLoaded) {
          final futureMatches = state.matches
              .where((m) => m.status == match_model.MatchStatus.scheduled)
              .where(
                (m) => tournamentId == null || m.tournamentId == tournamentId,
              )
              .toList();
          futureMatches.sort((a, b) => a.startTime.compareTo(b.startTime));

          final Map<String, List<match_model.Match>> groupedMatches = {};
          for (var match in futureMatches) {
            final dateKey =
                "${match.startTime.year}-${match.startTime.month}-${match.startTime.day}";
            if (!groupedMatches.containsKey(dateKey)) {
              groupedMatches[dateKey] = [];
            }
            groupedMatches[dateKey]!.add(match);
          }

          if (groupedMatches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 48, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  Text(
                    'No upcoming matches',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedMatches.length,
            itemBuilder: (context, index) {
              final dateKey = groupedMatches.keys.elementAt(index);
              final matches = groupedMatches[dateKey]!;
              final date = matches.first.startTime;

              final months = [
                'January',
                'February',
                'March',
                'April',
                'May',
                'June',
                'July',
                'August',
                'September',
                'October',
                'November',
                'December',
              ];
              final weekDays = [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday',
              ];

              final headerString =
                  "${weekDays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}";

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    child: Text(
                      headerString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...matches.map((match) => MatchCard(match: match)),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        }
        if (state is MatchLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Center(child: Text('No fixtures data'));
      },
    );
  }
}

class PlayerStatsTab extends StatefulWidget {
  final String? tournamentId;
  const PlayerStatsTab({super.key, this.tournamentId});

  @override
  State<PlayerStatsTab> createState() => _PlayerStatsTabState();
}

class _PlayerStatsTabState extends State<PlayerStatsTab> {
  @override
  void initState() {
    super.initState();
    _triggerFetch();
  }

  @override
  void didUpdateWidget(PlayerStatsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tournamentId != widget.tournamentId) {
      _triggerFetch();
    }
  }

  void _triggerFetch() {
    context.read<PlayerStatsCubit>().fetchPlayerStats(widget.tournamentId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerStatsCubit, PlayerStatsState>(
      builder: (context, state) {
        if (state is PlayerStatsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PlayerStatsError) {
          return Center(child: Text(state.message));
        }

        if (state is PlayerStatsLoaded) {
          final players = state.players;
          final teamMap = state.teamMap;

          if (players.isEmpty) {
            return const Center(child: Text('No player data available'));
          }

          final topScorers = List<Player>.from(players);
          topScorers.sort((a, b) => b.goals.compareTo(a.goals));
          final top3Scorers = topScorers.take(3).toList();

          final topAssists = List<Player>.from(players);
          topAssists.sort((a, b) => b.assists.compareTo(a.assists));
          final top3Assists = topAssists.take(3).toList();

          final combined = List<Player>.from(players);
          combined.sort(
            (a, b) => (b.goals + b.assists).compareTo(a.goals + a.assists),
          );
          final top3Combined = combined.take(3).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (top3Scorers.isNotEmpty) ...[
                _buildSectionHeader('Top Scorers'),
                ...top3Scorers.map(
                  (p) => _buildPlayerRow(
                    p.name,
                    teamMap[p.teamId] ?? 'Unknown',
                    p.goals.toString(),
                    '',
                    isHighlighted: top3Scorers.indexOf(p) == 0,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (top3Assists.isNotEmpty) ...[
                _buildSectionHeader('Top Assists'),
                ...top3Assists.map(
                  (p) => _buildPlayerRow(
                    p.name,
                    teamMap[p.teamId] ?? 'Unknown',
                    p.assists.toString(),
                    '',
                    isHighlighted: top3Assists.indexOf(p) == 0,
                    color: Colors.blue[400],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (top3Combined.isNotEmpty) ...[
                _buildSectionHeader('Goals + Assists'),
                ...top3Combined.map(
                  (p) => _buildPlayerRow(
                    p.name,
                    teamMap[p.teamId] ?? 'Unknown',
                    '${p.goals + p.assists}',
                    '',
                    isHighlighted: top3Combined.indexOf(p) == 0,
                    color: Colors.purple[400],
                  ),
                ),
              ],
            ],
          );
        }

        return const Center(child: Text('Initialize player stats...'));
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(
    String name,
    String team,
    String stat,
    String url, {
    bool isHighlighted = false,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[800],
            backgroundImage: url.isNotEmpty
                ? CachedNetworkImageProvider(url)
                : null,
            child: url.isEmpty ? Text(name.isNotEmpty ? name[0] : '?') : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  team,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? const Color(0xFF1E3A8A)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              stat,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    color ?? (isHighlighted ? Colors.blue[100] : Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TeamStatsTab extends StatelessWidget {
  final String? tournamentId;
  const TeamStatsTab({super.key, this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StandingsCubit, StandingsState>(
      builder: (context, state) {
        if (state is StandingsLoaded && state.tournaments.isNotEmpty) {
          final tournamentData = state.tournaments.firstWhere(
            (t) => t['tournament']['id'] == tournamentId,
            orElse: () => state.tournaments[0],
          );

          final List<dynamic> teamsJson = tournamentData['teams'];
          final List<standing_model.Standing> standings = teamsJson
              .map((s) => standing_model.Standing.fromJson(s))
              .toList();

          final bestAttack = List<standing_model.Standing>.from(standings);
          bestAttack.sort((a, b) => b.goalsFor.compareTo(a.goalsFor));

          final bestDefense = List<standing_model.Standing>.from(standings);
          bestDefense.sort((a, b) => a.goalsAgainst.compareTo(b.goalsAgainst));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('Best Attack'),
              ...bestAttack
                  .take(3)
                  .map(
                    (s) => _buildStatRow(
                      s.team?.name ?? 'Unknown',
                      s.goalsFor.toString(),
                      'Goals Scored',
                    ),
                  ),
              const SizedBox(height: 24),
              _buildSectionHeader('Best Defense'),
              ...bestDefense
                  .take(3)
                  .map(
                    (s) => _buildStatRow(
                      s.team?.name ?? 'Unknown',
                      s.goalsAgainst.toString(),
                      'Goals Conceded',
                    ),
                  ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildStatRow(String teamName, String value, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(teamName, style: const TextStyle(fontWeight: FontWeight.bold)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
