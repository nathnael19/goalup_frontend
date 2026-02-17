import 'package:flutter/material.dart';
import '../../models/standing.dart' as standing_model;
import '../../models/match.dart' as match_model;
import '../../utils/responsive.dart';

class StatsTab extends StatelessWidget {
  final String teamId;
  final List<standing_model.Standing>? standings;
  final List<match_model.Match>? matches;

  const StatsTab({
    super.key,
    required this.teamId,
    this.standings,
    this.matches,
  });

  @override
  Widget build(BuildContext context) {
    final standing = standings?.isNotEmpty == true ? standings!.first : null;

    if (standing == null) {
      return const Center(child: Text('No stats available'));
    }

    final int played = standing.played;
    final int goalsFor = standing.goalsFor;
    final int goalsAgainst = standing.goalsAgainst;

    // Calculate clean sheets from matches
    int cleanSheets = 0;
    if (matches != null) {
      for (var m in matches!) {
        // Only count finished matches
        if (m.status == match_model.MatchStatus.finished) {
          if (m.teamAId == teamId && m.scoreB == 0) {
            cleanSheets++;
          } else if (m.teamBId == teamId && m.scoreA == 0) {
            cleanSheets++;
          }
        }
      }
    }

    return ListView(
      padding: EdgeInsets.all(24.w),
      children: [
        _buildStatRow(
          context,
          'GOALS SCORED',
          goalsFor.toString(),
          played > 0 ? (goalsFor / (played * 3)).clamp(0, 1) : 0,
        ),
        _buildStatRow(
          context,
          'GOALS CONCEDED',
          goalsAgainst.toString(),
          played > 0 ? (goalsAgainst / (played * 3)).clamp(0, 1) : 0,
        ),
        _buildStatRow(
          context,
          'CLEAN SHEETS',
          cleanSheets.toString(),
          played > 0 ? (cleanSheets / played).clamp(0, 1) : 0,
        ),
        _buildStatRow(
          context,
          'WINS',
          standing.won.toString(),
          played > 0 ? (standing.won / played).clamp(0, 1) : 0,
        ),
        _buildStatRow(
          context,
          'DRAWS',
          standing.drawn.toString(),
          played > 0 ? (standing.drawn / played).clamp(0, 1) : 0,
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    double progress,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.w),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              minHeight: 6.h,
            ),
          ),
        ],
      ),
    );
  }
}
