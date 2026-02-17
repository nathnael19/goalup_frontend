import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../utils/responsive.dart';

class RosterTab extends StatelessWidget {
  final Map<String, List<Player>>? roster;

  const RosterTab({super.key, this.roster});

  @override
  Widget build(BuildContext context) {
    if (roster == null || roster!.isEmpty) {
      return const Center(child: Text('No roster information available'));
    }

    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        if (roster!['goalkeepers']?.isNotEmpty ?? false)
          ..._buildPositionSection('GOALKEEPERS', roster!['goalkeepers']!),
        if (roster!['defenders']?.isNotEmpty ?? false)
          ..._buildPositionSection('DEFENDERS', roster!['defenders']!),
        if (roster!['midfielders']?.isNotEmpty ?? false)
          ..._buildPositionSection('MIDFIELDERS', roster!['midfielders']!),
        if (roster!['forwards']?.isNotEmpty ?? false)
          ..._buildPositionSection('FORWARDS', roster!['forwards']!),
      ],
    );
  }

  List<Widget> _buildPositionSection(String title, List<Player> players) {
    return [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w900,
            color: Colors.grey[500],
            letterSpacing: 1.5,
          ),
        ),
      ),
      ...players.map((p) => _buildPlayerTile(p)),
    ];
  }

  Widget _buildPlayerTile(Player player) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 4.h),
      leading: CircleAvatar(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        child: Text(
          player.jerseyNumber.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
        ),
      ),
      title: Text(
        player.name,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
      ),
      subtitle: Text(
        player.position.toUpperCase(),
        style: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
      ),
      trailing: Text(
        player.goals > 0 ? '${player.goals} G' : '',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.greenAccent,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
