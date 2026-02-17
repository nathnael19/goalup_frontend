import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/standings_cubit.dart';
import '../cubits/match_cubit.dart';
import '../cubits/player_stats_cubit.dart';
import '../utils/responsive.dart';

// Tournament Tab Components
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
    _tabController = TabController(length: 4, vsync: this);

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
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.h,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "TOURNAMENT",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.sp,
                    letterSpacing: 1.2,
                  ),
                ),
                centerTitle: true,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
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
                    Tab(text: "STANDINGS"),
                    Tab(text: "FIXTURES"),
                    Tab(text: "PLAYER STATS"),
                    Tab(text: "TEAM STATS"),
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
