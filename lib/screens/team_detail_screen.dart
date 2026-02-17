import 'package:flutter/material.dart';
import '../models/team.dart' as model;
import '../services/api_service.dart';
import '../utils/responsive.dart';

// Team Detail Components
import 'team_detail/team_header.dart';
import 'team_detail/roster_tab.dart';
import 'team_detail/stats_tab.dart';
import 'team_detail/matches_tab.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _detailedTeam.name.toUpperCase(),
          style: TextStyle(
            fontSize: 14.sp,
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
                TeamHeader(team: _detailedTeam),

                // Tabs
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
                      RosterTab(roster: _detailedTeam.roster),
                      StatsTab(
                        teamId: _detailedTeam.id,
                        standings: _detailedTeam.standings,
                        matches: _detailedTeam.matches,
                      ),
                      MatchesTab(matches: _detailedTeam.matches),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
