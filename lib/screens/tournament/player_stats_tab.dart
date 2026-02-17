import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../cubits/player_stats_cubit.dart';
import '../../models/player.dart';
import '../../utils/responsive.dart';

class PlayerStatsTab extends StatefulWidget {
  final String? competitionId;
  final String? tournamentId;
  const PlayerStatsTab({super.key, this.competitionId, this.tournamentId});

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
    if (oldWidget.tournamentId != widget.tournamentId ||
        oldWidget.competitionId != widget.competitionId) {
      _triggerFetch();
    }
  }

  void _triggerFetch() {
    context.read<PlayerStatsCubit>().fetchPlayerStats(
      tournamentId: widget.tournamentId,
      competitionId: widget.competitionId,
    );
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
                SizedBox(height: 24.h),
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
                SizedBox(height: 24.h),
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
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          Icon(Icons.chevron_right, color: Colors.grey, size: 20.sp),
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
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.w,
            backgroundColor: Colors.grey[800],
            backgroundImage: url.isNotEmpty
                ? CachedNetworkImageProvider(url)
                : null,
            child: url.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: TextStyle(fontSize: 16.sp),
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  team,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? const Color(0xFF1E3A8A)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Text(
              stat,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
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
