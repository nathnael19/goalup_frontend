import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/team.dart' as model;
import '../../services/api_service.dart';
import '../../utils/responsive.dart';

class TeamHeader extends StatelessWidget {
  final model.Team team;

  const TeamHeader({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.w),
          bottomRight: Radius.circular(40.w),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 4.w,
              ),
            ),
            child: Center(child: _buildTeamLogo(colorScheme)),
          ),
          SizedBox(height: 20.h),
          Text(
            team.name,
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          if (team.stadium != null) ...[
            Text(
              team.stadium!.toUpperCase(),
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
                fontSize: 12.sp,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (team.tournament != null)
            Text(
              team.tournament!.name.toUpperCase(),
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
                letterSpacing: 1,
              ),
            )
          else
            Text(
              (team.batch ?? 'N/A').toUpperCase(),
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
                fontSize: 12.sp,
                letterSpacing: 1,
              ),
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickStat('RANK', _getRank()),
              _buildDivider(),
              _buildQuickStat('POINTS', _getPoints()),
              _buildDivider(),
              _buildQuickStat('PLAYED', _getPlayed()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLogo(ColorScheme colorScheme) {
    final logoUrl = ApiService.getImageFullUrl(team.logoUrl);
    if (logoUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: logoUrl,
        memCacheHeight: 100, // Optimize memory usage
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        placeholder: (context, url) =>
            const CircularProgressIndicator(strokeWidth: 2),
        errorWidget: (context, error, stackTrace) =>
            _buildLogoPlaceholder(colorScheme),
      );
    }
    return _buildLogoPlaceholder(colorScheme);
  }

  Widget _buildLogoPlaceholder(ColorScheme colorScheme) {
    return Text(
      team.name.isNotEmpty ? team.name[0] : 'T',
      style: TextStyle(
        color: colorScheme.primary,
        fontSize: 48.sp,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 9.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24.h,
      width: 1.w,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      color: Colors.white.withValues(alpha: 0.05),
    );
  }

  String _getRank() {
    if (team.standings == null || team.standings!.isEmpty) {
      return '-';
    }
    return 'N/A';
  }

  String _getPoints() {
    if (team.standings == null || team.standings!.isEmpty) {
      return '0';
    }
    return team.standings!.first.points.toString();
  }

  String _getPlayed() {
    if (team.standings == null || team.standings!.isEmpty) {
      return '0';
    }
    return team.standings!.first.played.toString();
  }
}
