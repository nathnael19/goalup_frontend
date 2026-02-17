import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match.dart' as model;
import '../screens/tournament_screen.dart';
import '../services/api_service.dart';
import '../utils/responsive.dart';

class MatchCard extends StatelessWidget {
  final model.Match match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final isLive = match.status == model.MatchStatus.live;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(
          color: isLive
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 2.w,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Tournament & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (match.tournament?.competition != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TournamentScreen(
                            competitionId: match.tournament!.competition!.id,
                          ),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 14.sp,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        (match.tournament?.competition?.name ??
                                match.tournament?.name ??
                                'TOURNAMENT')
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.chevron_right,
                        size: 12.sp,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                if (isLive)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                    child: Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Text(
                    match.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // Teams & Score
            Row(
              children: [
                // Home Team
                Expanded(
                  child: Column(
                    children: [
                      _buildTeamLogo(
                        match.teamA?.name ?? 'T1',
                        match.teamA?.logoUrl,
                        colorScheme,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        match.teamA?.name ?? 'T1',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Score Area
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      Text(
                        '${match.scoreA} - ${match.scoreB}',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        isLive ? 'LIVE' : 'Final',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isLive ? Colors.red : Colors.grey[400],
                          fontWeight: isLive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                // Away Team
                Expanded(
                  child: Column(
                    children: [
                      _buildTeamLogo(
                        match.teamB?.name ?? 'T2',
                        match.teamB?.logoUrl,
                        colorScheme,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        match.teamB?.name ?? 'T2',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String name, String? logoUrl, ColorScheme colorScheme) {
    final fullUrl = ApiService.getImageFullUrl(logoUrl);
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: fullUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: fullUrl,
              memCacheHeight: 100, // Optimize memory usage
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
                  _buildLogoPlaceholder(name),
            )
          : _buildLogoPlaceholder(name),
    );
  }

  Widget _buildLogoPlaceholder(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name.substring(0, 1) : '?',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
          color: Colors.white70,
        ),
      ),
    );
  }
}
