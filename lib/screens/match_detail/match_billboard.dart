import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/match.dart' as model;
import '../../models/team.dart';
import '../../services/api_service.dart';
import '../../utils/responsive.dart';
import '../team_detail_screen.dart';

class MatchBillboard extends StatelessWidget {
  final model.Match match;

  const MatchBillboard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.w),
          bottomRight: Radius.circular(40.w),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTeamInfo(context, match.teamA, 'T1', isHome: true),
              ),
              _buildScoreInfo(match),
              Expanded(
                child: _buildTeamInfo(
                  context,
                  match.teamB,
                  'T2',
                  isHome: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            match.venue ?? 'Main Stadium, ASTU',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(
    BuildContext context,
    Team? team,
    String fallbackName, {
    required bool isHome,
  }) {
    final teamName = team?.name ?? fallbackName;
    final logoUrl = ApiService.getImageFullUrl(team?.logoUrl);

    return GestureDetector(
      onTap: () {
        if (team != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamDetailScreen(team: team),
            ),
          );
        }
      },
      child: Column(
        children: [
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 2.w,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35.w),
              child: logoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: logoUrl,
                      fit: BoxFit.cover,
                      memCacheHeight: 140, // Optimized for 70.w
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, error, stackTrace) =>
                          _buildLogoPlaceholder(teamName),
                    )
                  : _buildLogoPlaceholder(teamName),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            teamName,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPlaceholder(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name.substring(0, 1) : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: 32.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildScoreInfo(model.Match match) {
    final isLive = match.status == model.MatchStatus.live;
    return Column(
      children: [
        Text(
          '${match.scoreA} - ${match.scoreB}',
          style: TextStyle(
            fontSize: 48.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isLive ? Colors.red : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20.w),
          ),
          child: Text(
            isLive ? 'LIVE' : 'FINAL',
            style: TextStyle(
              color: isLive ? Colors.white : Colors.grey[400],
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
