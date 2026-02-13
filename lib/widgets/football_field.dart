import 'package:flutter/material.dart';

import '../models/event.dart';

class FootballFieldWidget extends StatelessWidget {
  final List<Lineup> lineup;
  final String formation;
  final bool isHome;
  final Color teamColor;

  const FootballFieldWidget({
    super.key,
    required this.lineup,
    required this.formation,
    required this.isHome,
    required this.teamColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4D3E), // Grass green
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 3,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            // Field Patterns
            _buildFieldPattern(),

            // Markings
            _buildFieldMarkings(),

            // Players
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _buildFormationRows(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldPattern() {
    return Row(
      children: List.generate(
        6,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildFieldMarkings() {
    return Stack(
      children: [
        // Center Line
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              height: 2,
              width: double.infinity,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ),
        // Center Circle
        Positioned.fill(
          child: Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        // Goal Areas (Simplified)
        Positioned(
          top: 0,
          left: 100,
          right: 100,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
                left: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
                right: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 100,
          right: 100,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
                left: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
                right: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<int> _getFormationCounts() {
    switch (formation) {
      case '4-4-2':
        return [1, 4, 4, 2];
      case '4-2-3-1':
        return [1, 4, 2, 3, 1];
      case '4-3-2-1':
        return [1, 4, 3, 2, 1];
      case '3-5-2':
        return [1, 3, 5, 2];
      case '5-3-2':
        return [1, 5, 3, 2];
      case '4-5-1':
        return [1, 4, 5, 1];
      case '3-4-3':
        return [1, 3, 4, 3];
      case '4-3-3':
      default:
        return [1, 4, 3, 3];
    }
  }

  List<Widget> _buildFormationRows(BuildContext context) {
    final counts = _getFormationCounts();
    // Invert order for away team if needed?
    // Usually standard view is GK at bottom or top.
    // Let's assume GK is at the top for now as it maps to the rows starting with 1.
    // If we want GK at bottom, we reverse the list.
    // Standard tactical view usually has GK at bottom, but vertical lists often start with GK.
    // Admin view:
    // [1, "gk"], [4, "def"], ...
    // And renderTacticalRows maps them.
    // If I use Column, top is top of screen.
    // If I want GK at bottom, I should reverse `counts`.
    // Let's stick to GK at top for now or check admin visual.
    // Admin visual:
    // <div className="absolute inset-0 p-4 py-8 flex flex-col-reverse justify-between">
    //   flex-col-reverse -> so the first row in DOM (which is GK from getFormationRows) is at the BOTTOM.
    // So GK is at the BOTTOM.

    // So I should reverse the counts if I am using a standard Column.
    // Or use mainAxisAlignment: MainAxisAlignment.end and reverse children.

    // Wait, getFormationRows returns [GK, DEF, MID, FWD].
    // If I render them in a Column:
    // GK
    // DEF
    // MID
    // FWD
    // This puts GK at the TOP.

    // Admin uses flex-col-reverse, so:
    // FWD
    // MID
    // DEF
    // GK (Bottom)

    // I will render GK at the bottom too.
    // So I will reverse the counts list if I want GK at bottom.
    // Actually, `counts` is [1, 4, 3, 3].
    // If I reverse it -> [3, 3, 4, 1].
    // Row 0: 3 FWD
    // Row 1: 3 MID
    // Row 2: 4 DEF
    // Row 3: 1 GK

    int currentSlotIndex = 0;

    // We process the layout in standard order (GK -> FWD) to assign correct slot indices
    // But we will collect the widgets and then flip them for display so GK is at bottom.

    final rowWidgets = <Widget>[];

    for (int count in counts) {
      final rowPlayers = <Lineup?>[];

      for (int i = 0; i < count; i++) {
        final slotIdx = currentSlotIndex++;
        // Find player with this slot index
        try {
          final player = lineup.firstWhere(
            (element) => element.slotIndex == slotIdx,
          );
          rowPlayers.add(player);
        } catch (e) {
          rowPlayers.add(null);
        }
      }

      rowWidgets.add(_buildPlayerRow(rowPlayers));
    }

    // Return reversed so GK (first processed) is at bottom
    return rowWidgets.reversed.toList();
  }

  Widget _buildPlayerRow(List<Lineup?> players) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: players.map((l) => _buildPlayer(l)).toList(),
    );
  }

  Widget _buildPlayer(Lineup? lineup) {
    if (lineup == null) {
      return const SizedBox(width: 40, height: 60); // Empty slot placeholder
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: teamColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              lineup.player?.jerseyNumber.toString() ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            lineup.player?.name.split(' ').last ?? 'Player',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
