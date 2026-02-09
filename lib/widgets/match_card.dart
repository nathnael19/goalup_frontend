import 'package:flutter/material.dart';
import '../models/match.dart' as model;

class MatchCard extends StatelessWidget {
  final model.Match match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final isLive = match.status == model.MatchStatus.live;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLive
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tournament & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (match.tournament?.name ?? 'TOURNAMENT').toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Text(
                    match.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
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
                      _buildTeamLogo(match.teamA?.name ?? 'T1'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        '${match.scoreA} - ${match.scoreB}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLive ? '67\'' : 'Final', // Mocking time for now
                        style: TextStyle(
                          fontSize: 12,
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
                      _buildTeamLogo(match.teamB?.name ?? 'T2'),
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

  Widget _buildTeamLogo(String name) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name.substring(0, 1) : '?',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
