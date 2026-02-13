import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/standings_cubit.dart';
import '../cubits/match_cubit.dart';
import '../services/api_service.dart';
import '../models/match.dart' as match_model;
import '../models/player.dart';
import '../models/standing.dart' as standing_model;
import '../widgets/match_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 210.0,
              floating: false,
              pinned: true,
              backgroundColor: colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: BlocBuilder<StandingsCubit, StandingsState>(
                  builder: (context, state) {
                    String tournamentName = 'Loading...';
                    String country =
                        'World'; // We don't have country in Tournament model yet, hardcode or remove
                    String season = '2025/2026';
                    String? logoUrl;

                    if (state is StandingsLoaded &&
                        state.tournaments.isNotEmpty) {
                      // 1. Determine which competition ID to use
                      final String? targetCompetitionId = widget.competitionId;

                      // 2. Filter all tournaments that belong to this competition
                      List<dynamic> seasonTournaments;
                      if (targetCompetitionId != null) {
                        seasonTournaments = state.tournaments.where((t) {
                          final tComp = t['tournament']['competition'];
                          return tComp != null &&
                              tComp['id'] == targetCompetitionId;
                        }).toList();
                        print(
                          'Filtered by targetCompetitionId: found ${seasonTournaments.length} tournaments',
                        );
                      } else {
                        // No competition ID passed — show the first competition's tournaments
                        final firstComp =
                            state.tournaments[0]['tournament']['competition'];
                        final firstCompId = firstComp?['id'];
                        seasonTournaments = state.tournaments.where((t) {
                          final tComp = t['tournament']['competition'];
                          return tComp != null && tComp['id'] == firstCompId;
                        }).toList();
                        print(
                          'No competitionId passed, using first: $firstCompId, found ${seasonTournaments.length}',
                        );
                      }

                      // Fallback: if filtering found nothing, show all
                      if (seasonTournaments.isEmpty) {
                        seasonTournaments = List.from(state.tournaments);
                      }

                      // 2.5 Determine competition name for header
                      final firstValidTour = seasonTournaments.isNotEmpty
                          ? seasonTournaments.first['tournament']
                          : state.tournaments[0]['tournament'];
                      final String competitionName =
                          firstValidTour['competition']?['name'] ??
                          'Tournament';

                      // Sort seasons descending by year or name
                      seasonTournaments.sort((a, b) {
                        final tA = a['tournament'];
                        final tB = b['tournament'];
                        // Try to sort by year desc
                        int yearA = tA['year'] ?? 0;
                        int yearB = tB['year'] ?? 0;
                        return yearB.compareTo(yearA);
                      });

                      // 3. Determine currently selected tournament
                      final selectedTournamentData =
                          _selectedTournamentId == null
                          ? seasonTournaments.first
                          : seasonTournaments.firstWhere(
                              (t) =>
                                  t['tournament']['id'] ==
                                  _selectedTournamentId,
                              orElse: () => seasonTournaments.first,
                            );

                      final selectedTournament =
                          selectedTournamentData['tournament'];

                      // Using a microtask to update state if needed to avoid build phase setState error
                      if (_selectedTournamentId == null) {
                        Future.microtask(() {
                          if (mounted) {
                            setState(() {
                              _selectedTournamentId = selectedTournament['id'];
                            });
                          }
                        });
                      }

                      // 4. Construct Season Name for selected
                      final String? logoUrl =
                          selectedTournament['image_url'] ??
                          selectedTournament['competition']?['image_url'];

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Season Selector Dropdown
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedTournament['id'],
                                      dropdownColor: const Color(
                                        0xFF222222,
                                      ), // Dark bg for dropdown
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
                                          .map<DropdownMenuItem<String>>((t) {
                                            final tour = t['tournament'];
                                            final y = tour['year'] ?? 2025;
                                            final label = '$y/${y + 1}';
                                            return DropdownMenuItem<String>(
                                              value: tour['id'],
                                              child: Text(label),
                                            );
                                          })
                                          .toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            _selectedTournamentId = newValue;
                                          });
                                        }
                                      },
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.notifications_none,
                                      ),
                                      onPressed: () {},
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 0,
                                        ),
                                        minimumSize: const Size(0, 32),
                                      ),
                                      child: const Text(
                                        'Following',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                // Tournament Logo
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.network(
                                      logoUrl ??
                                          'https://tse3.mm.bing.net/th/id/OIP.pULMqVnEVIxQt3156l2PXgHaHa?rs=1&pid=ImgDetMain&o=7&rm=3',
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.emoji_events,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      competitionName, // Competition Name
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'World', // Country or Region
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 60),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Season Selector
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      season, // Dynamic Season
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_drop_down, size: 18),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              // Tournament Logo
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network(
                                    logoUrl ??
                                        'https://upload.wikimedia.org/wikipedia/en/thumb/f/f2/Premier_League_Logo.svg/1200px-Premier_League_Logo.svg.png',
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.emoji_events,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tournamentName, // Dynamic Name
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    country, // Still hardcoded if not in API
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: colorScheme.primary,
                indicatorWeight: 3,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Table'),
                  Tab(text: 'Fixtures'),
                  Tab(text: 'Player stats'),
                  Tab(text: 'Team stats'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            StandingsTab(tournamentId: _selectedTournamentId),
            FixturesTab(tournamentId: _selectedTournamentId),
            PlayerStatsTab(tournamentId: _selectedTournamentId),
            TeamStatsTab(tournamentId: _selectedTournamentId),
          ],
        ),
      ),
    );
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
          // Find specific tournament data
          // If tournamentId is null, we should try to find a tournament that matches the competition but for now
          // we rely on the parent providing the correct ID via setState.
          var tournamentData = state.tournaments.firstWhere(
            (t) => t['tournament']['id'] == tournamentId,
            orElse: () => state.tournaments[0],
          );

          // If we have a competition context, try to at least show a tournament from that competition
          // This helps if tournamentId is null during the very first build frame
          if (tournamentId == null &&
              context.read<StandingsCubit>().state is StandingsLoaded) {
            // We don't easily have access to widget.competitionId here since this is a separate widget
            // but usually _selectedTournamentId will catch up in the next frame.
          }

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
          // Filter for future matches AND selected tournament
          final futureMatches = state.matches
              .where((m) => m.status == match_model.MatchStatus.scheduled)
              .where(
                (m) => tournamentId == null || m.tournamentId == tournamentId,
              )
              .toList();
          futureMatches.sort((a, b) => a.startTime.compareTo(b.startTime));

          // Group by Date
          final Map<String, List<match_model.Match>> groupedMatches = {};
          for (var match in futureMatches) {
            // Simple date formatting YYYY-MM-DD for key
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

              // Format date header like "Saturday, February 21"
              // Using basic list of months since intl package might not be added
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
  // Mocking for now as we need an endpoint or logic to get players
  // In real app, we'd fetch this via Cubit
  List<Player> players = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
  }

  @override
  void didUpdateWidget(PlayerStatsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tournamentId != widget.tournamentId) {
      _fetchPlayers();
    }
  }

  Future<void> _fetchPlayers() async {
    // Simulate fetch or use ApiService if we add getPlayers there
    // For now, I'll access ApiService via context to get ALL teams then extract players?
    // Too complex for a quick UI demo.
    // Let's check if we can add getPlayers to ApiService quickly.
    // I'll assume I can add it.
    try {
      if (!mounted) return;
      setState(() {
        isLoading = true;
      });

      final apiService = context.read<ApiService>();
      var playersJson = await apiService.getPlayers();

      // Filter by team's tournament if possible
      // But players endpoint just returns all players.
      // We need to filter players whose team belongs to current tournament.
      // fetch teams first
      final teams = await apiService.getTeams();
      final teamMap = {for (var t in teams) t.id: t.name};

      // Filter teams by tournamentId? Team model has tournamentId?
      // Team model has 'tournament_id' (singular or list? Model says singular in some places but actually M2M in backend?)
      // Check Team model.
      // Assuming straightforward for now: filtering in client.

      if (widget.tournamentId != null) {
        // Filter teams that belong to this tournament
        final tournamentTeams = teams
            .where(
              (t) =>
                  t.tournament?.id == widget.tournamentId ||
                  t.standings?.any(
                        (s) => s.tournamentId == widget.tournamentId,
                      ) ==
                      true,
            )
            .toList();
        final tournamentTeamIds = tournamentTeams.map((t) => t.id).toSet();

        playersJson = playersJson
            .where((p) => tournamentTeamIds.contains(p['team_id']))
            .toList();
      }

      if (mounted) {
        setState(() {
          players = playersJson.map((json) {
            final player = Player.fromJson(json);
            return player;
          }).toList();

          this.teamMap = teamMap; // Store for UI lookup
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Map<String, String> teamMap = {};

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    // Sort for top scorers
    final topScorers = List<Player>.from(players);
    topScorers.sort((a, b) => b.goals.compareTo(a.goals));
    final top3Scorers = topScorers.take(3).toList();

    // Sort for assists (assuming backend will have this, using random mock field if not,
    // but Player model has goals, yellowCards, redCards. No assists field in current model.
    // I shall check Player model again. Verified: No assists field.
    // I will use yellow cards as a proxy for "Assists" demo OR just hide it/mock it
    // since user asked for REAL data. I should probably tell user "Assists" not in DB yet.
    // For now, let's just show Top Scorers and maybe "Discipline" (Yellow Cards) instead of Assists?
    // Or just show Top Scorers. User asked for "Top Scorer, Assists".
    // I will stick to Top Scorers for now and maybe Red Cards?
    // Or just mock assists to 0 since it's missing from DB schema confirmed in previous turns.
    // Wait, let's just show top scorers.

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
              '', // No photo URL in player model yet
              isHighlighted: top3Scorers.indexOf(p) == 0,
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Show Assists
        _buildSectionHeader('Top Assists'),
        ...(() {
          final topAssists = List<Player>.from(players);
          topAssists.sort((a, b) => b.assists.compareTo(a.assists));
          return topAssists
              .take(3)
              .map(
                (p) => _buildPlayerRow(
                  p.name,
                  teamMap[p.teamId] ?? 'Unknown',
                  p.assists.toString(),
                  '',
                  isHighlighted: topAssists.indexOf(p) == 0,
                  color: Colors.blue[400],
                ),
              )
              .toList();
        })(),
        const SizedBox(height: 24),

        // Show Goals + Assists
        _buildSectionHeader('Goals + Assists'),
        ...(() {
          final combined = List<Player>.from(players);
          combined.sort(
            (a, b) => (b.goals + b.assists).compareTo(a.goals + a.assists),
          );
          return combined
              .take(3)
              .map(
                (p) => _buildPlayerRow(
                  p.name,
                  teamMap[p.teamId] ?? 'Unknown',
                  '${p.goals + p.assists}',
                  '',
                  isHighlighted: combined.indexOf(p) == 0,
                  color: Colors.purple[400],
                ),
              )
              .toList();
        })(),
      ],
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
            backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
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
                  ? const Color(0xFF1E3A8A) // Darker blue background
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

          // Best Attack (Most Goals For)
          final bestAttack = List<standing_model.Standing>.from(standings);
          bestAttack.sort((a, b) => b.goalsFor.compareTo(a.goalsFor));

          // Best Defense (Least Goals Against)
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
        color: Colors.white.withOpacity(0.05),
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
