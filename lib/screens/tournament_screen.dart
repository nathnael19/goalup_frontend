import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/standings_cubit.dart';
import '../cubits/match_cubit.dart';
import '../cubits/player_stats_cubit.dart';
import '../cubits/tournament_cubit.dart';
import '../utils/responsive.dart';
import '../services/api_service.dart';

// Tournament Tab Components
import 'news_feed_screen.dart';
import 'tournament/standings_tab.dart';
import 'tournament/fixtures_tab.dart';
import 'tournament/player_stats_tab.dart';
import 'tournament/team_stats_tab.dart';

class TournamentScreen extends StatefulWidget {
  final String? competitionId;
  final String? tournamentId;

  const TournamentScreen({super.key, this.competitionId, this.tournamentId});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Fetch all necessary data
    context.read<StandingsCubit>().fetchStandings();
    context.read<MatchCubit>().fetchMatches();
    context.read<PlayerStatsCubit>().fetchPlayerStats(
      tournamentId: widget.tournamentId,
      competitionId: widget.competitionId,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TournamentCubit()..fetchTournament(widget.tournamentId),
      child: Builder(builder: (context) => _buildScaffold(context)),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (hContext, innerBoxIsScrolled) {
          return [
            BlocBuilder<TournamentCubit, TournamentState>(
              builder: (context, state) {
                String title = "";
                String? logoUrl;
                String competitionName = "";

                if (state is TournamentLoaded) {
                  title = state.tournament.name;
                  logoUrl = state.tournament.competition?.imageUrl;
                  competitionName = state.tournament.competition?.name ?? "";
                }

                return SliverAppBar(
                  expandedHeight: 180.h,
                  floating: false,
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  centerTitle: false,
                  title: Text(
                    competitionName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Padding(
                      padding: EdgeInsets.only(left: 16.w, top: 100.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Tournament Logo
                          if (logoUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.w),
                              child: Image.network(
                                ApiService.getImageFullUrl(logoUrl),
                                height: 64.h,
                                width: 64.h,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.sports_soccer,
                                      size: 64.h,
                                      color: Colors.white24,
                                    ),
                              ),
                            )
                          else
                            Icon(
                              Icons.sports_soccer,
                              size: 64.h,
                              color: Colors.white24,
                            ),
                          SizedBox(width: 16.w),
                          // Name and Subtitle
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  competitionName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  title,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Seasons Dropdown
                          if (state is TournamentLoaded &&
                              state.seasons.isNotEmpty)
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: state.tournament.id,
                                dropdownColor: const Color(0xFF1E1E1E),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                                items: state.seasons.map((season) {
                                  return DropdownMenuItem<String>(
                                    value: season.id,
                                    child: Text(
                                      season.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (selectedId) {
                                  if (selectedId != null &&
                                      selectedId != state.tournament.id) {
                                    // Navigate to the selected season's tournament
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TournamentScreen(
                                          competitionId:
                                              state.tournament.competitionId,
                                          tournamentId: selectedId,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          SizedBox(width: 16.w),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  indicatorColor: const Color(
                    0xFF00FF85,
                  ), // Reference Green Indicator
                  indicatorWeight: 3,
                  labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                  tabs: const [
                    Tab(text: "Table"),
                    Tab(text: "Fixtures"),
                    Tab(text: "News"),
                    Tab(text: "Player stats"),
                    Tab(text: "Team stats"),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            StandingsTab(
              competitionId: widget.competitionId,
              tournamentId: widget.tournamentId,
            ),
            FixturesTab(
              competitionId: widget.competitionId,
              tournamentId: widget.tournamentId,
            ),
            const NewsFeedScreen(),
            PlayerStatsTab(
              competitionId: widget.competitionId,
              tournamentId: widget.tournamentId,
            ),
            TeamStatsTab(
              competitionId: widget.competitionId,
              tournamentId: widget.tournamentId,
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

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
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
