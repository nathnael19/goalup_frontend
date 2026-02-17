import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/standing.dart' as model;
import '../services/api_service.dart';
import '../screens/team_detail_screen.dart';
import '../utils/responsive.dart';

/// Standings Table Widget
class StandingsTable extends StatelessWidget {
  final List<model.Standing> standings;

  const StandingsTable({super.key, required this.standings});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (standings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 80.sp,
              color: Colors.grey[800],
            ),
            SizedBox(height: 16.h),
            Text(
              'No standings available',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          // Table header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.w),
                topRight: Radius.circular(16.w),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32.w,
                  child: Text(
                    '#',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10.sp,
                      color: Colors.grey[500],
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'TEAM',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10.sp,
                      color: Colors.grey[500],
                      letterSpacing: 1,
                    ),
                  ),
                ),
                _buildHeaderCell('P'),
                _buildHeaderCell('W'),
                _buildHeaderCell('D'),
                _buildHeaderCell('L'),
                _buildHeaderCell('GD'),
                SizedBox(
                  width: 32.w,
                  child: Text(
                    'Pts',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10.sp,
                      color: colorScheme.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
              ],
            ),
          ),
          // Table rows
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: standings.length,
            itemBuilder: (context, index) {
              final standing = standings[index];
              final goalDifference = standing.goalsFor - standing.goalsAgainst;
              final rank = index + 1;
              final isTopThree = rank <= 3;
              final bool isLast = index == standings.length - 1;

              return InkWell(
                onTap: standing.team != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TeamDetailScreen(team: standing.team!),
                          ),
                        );
                      }
                    : null,
                borderRadius: isLast
                    ? BorderRadius.only(
                        bottomLeft: Radius.circular(16.w),
                        bottomRight: Radius.circular(16.w),
                      )
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer.withValues(
                      alpha: index % 2 == 0 ? 0.3 : 0.6,
                    ),
                    borderRadius: isLast
                        ? BorderRadius.only(
                            bottomLeft: Radius.circular(16.w),
                            bottomRight: Radius.circular(16.w),
                          )
                        : null,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  child: Row(
                    children: [
                      // Rank
                      SizedBox(
                        width: 32.w,
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            fontWeight: isTopThree
                                ? FontWeight.w900
                                : FontWeight.bold,
                            color: rank == 1
                                ? Colors.amber
                                : rank == 2
                                ? Colors.grey[400]
                                : rank == 3
                                ? Colors.brown[300]
                                : Colors.grey[500],
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      // Team Logo & Name
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            _buildTeamLogo(
                              standing.team?.logoUrl,
                              standing.team?.name ?? '?',
                              colorScheme,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                standing.team?.name ?? 'UNKNOWN',
                                style: TextStyle(
                                  fontWeight: isTopThree
                                      ? FontWeight.w900
                                      : FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Stats
                      _buildStatCell('${standing.played}'),
                      _buildStatCell('${standing.won}'),
                      _buildStatCell('${standing.drawn}'),
                      _buildStatCell('${standing.lost}'),
                      _buildStatCell(
                        goalDifference >= 0
                            ? '+$goalDifference'
                            : '$goalDifference',
                        color: goalDifference > 0
                            ? Colors.greenAccent
                            : goalDifference < 0
                            ? Colors.redAccent
                            : Colors.grey[600],
                      ),
                      // Points
                      SizedBox(
                        width: 32.w,
                        child: Text(
                          '${standing.points}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isTopThree
                                ? colorScheme.primary
                                : Colors.white,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                    ],
                  ),
                ),
              );
            },
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'LEGEND',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildLegendItem('P', 'Played'),
                    _buildLegendItem('W', 'Won'),
                    _buildLegendItem('D', 'Drawn'),
                    _buildLegendItem('L', 'Lost'),
                    _buildLegendItem('GD', 'Goal Difference'),
                    _buildLegendItem('PTS', 'Points'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLogo(String? logoUrl, String name, ColorScheme colorScheme) {
    final fullLogoUrl = ApiService.getImageFullUrl(logoUrl);

    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: fullLogoUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: fullLogoUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 1),
                ),
                errorWidget: (context, error, stackTrace) =>
                    _buildLogoPlaceholder(name, colorScheme),
              )
            : _buildLogoPlaceholder(name, colorScheme),
      ),
    );
  }

  Widget _buildLogoPlaceholder(String name, ColorScheme colorScheme) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0] : '?',
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 10.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return SizedBox(
      width: 30.w,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 10.sp,
          color: Colors.grey[500],
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildStatCell(String text, {Color? color}) {
    return SizedBox(
      width: 30.w,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color ?? Colors.white70,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegendItem(String abbr, String full) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$abbr ',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
        Text(
          full,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
