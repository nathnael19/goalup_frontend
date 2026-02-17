import 'package:flutter/material.dart';
import 'package:goalup/widgets/football_field.dart';
import '../../models/match.dart' as model;
import '../../utils/responsive.dart';

class MatchLineups extends StatelessWidget {
  final model.Match match;

  const MatchLineups({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final homeLineup =
        match.lineups
            ?.where((l) => l.teamId == match.teamAId && l.isStarting)
            .toList() ??
        [];
    final awayLineup =
        match.lineups
            ?.where((l) => l.teamId == match.teamBId && l.isStarting)
            .toList() ??
        [];

    final homeFormation = match.formationA ?? '4-3-3';
    final awayFormation = match.formationB ?? '4-3-3';

    if (homeLineup.isEmpty && awayLineup.isEmpty) {
      return Center(
        child: Text(
          'Lineups not available',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildTeamLineupHeader(
            context,
            match.teamA?.name ?? 'Home',
            homeFormation,
            Theme.of(context).primaryColor,
          ),
          SizedBox(
            height: 450.h,
            child: FootballFieldWidget(
              lineup: homeLineup,
              formation: homeFormation,
              isHome: true,
              teamColor: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 32.h),
          _buildTeamLineupHeader(
            context,
            match.teamB?.name ?? 'Away',
            awayFormation,
            Colors.red,
          ),
          SizedBox(
            height: 450.h,
            child: FootballFieldWidget(
              lineup: awayLineup,
              formation: awayFormation,
              isHome: false,
              teamColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLineupHeader(
    BuildContext context,
    String teamName,
    String formation,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                teamName.toUpperCase(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.w),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Text(
              formation,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
