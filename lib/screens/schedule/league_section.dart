import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/match.dart' as model;
import '../../services/api_service.dart';
import '../../utils/responsive.dart';
import '../match_detail_screen.dart';
import '../tournament_screen.dart';

class LeagueSection extends StatelessWidget {
  final String name;
  final List<model.Match> matches;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const LeagueSection({
    super.key,
    required this.name,
    required this.matches,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final String? competitionId = matches.isNotEmpty
        ? matches.first.tournament?.competition?.id
        : null;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TournamentScreen(competitionId: competitionId),
              ),
            );
          },
          child: _buildCollapseHeader(
            name,
            matches.length.toString(),
            isCollapsed,
            leading: _buildFlagPlaceholder(),
            onToggle: onToggle,
          ),
        ),
        if (!isCollapsed)
          ...matches.map((match) => _buildMatchItem(context, match)),
        SizedBox(height: 12.h),
      ],
    );
  }

  Widget _buildCollapseHeader(
    String title,
    String count,
    bool isCollapsed, {
    Widget? leading,
    VoidCallback? onToggle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading, SizedBox(width: 12.w)],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
          ),
          if (count.isNotEmpty)
            Text(
              count,
              style: TextStyle(color: Colors.grey, fontSize: 13.sp),
            ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: Colors.grey,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchItem(BuildContext context, model.Match match) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailScreen(match: match),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                match.teamA?.name ?? '',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            _buildTeamLogo(match.teamA?.logoUrl, match.teamA?.name ?? 'A'),
            SizedBox(width: 12.w),
            Column(
              children: [
                Text(
                  match.status == model.MatchStatus.finished
                      ? '${match.scoreA} - ${match.scoreB}'
                      : DateFormat('HH:mm').format(match.startTime),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
                if (match.status == model.MatchStatus.live)
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            _buildTeamLogo(match.teamB?.logoUrl, match.teamB?.name ?? 'B'),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                match.teamB?.name ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String? logoUrl, String name) {
    final fullLogoUrl = ApiService.getImageFullUrl(logoUrl);

    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.w),
        child: fullLogoUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: fullLogoUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 1),
                ),
                errorWidget: (context, error, stackTrace) =>
                    _buildLogoPlaceholder(name),
              )
            : _buildLogoPlaceholder(name),
      ),
    );
  }

  Widget _buildLogoPlaceholder(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0] : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFlagPlaceholder() {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
