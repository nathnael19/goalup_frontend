import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/match_cubit.dart';
import '../../models/match.dart' as match_model;
import '../../widgets/match_card.dart';
import '../../utils/responsive.dart';

class FixturesTab extends StatelessWidget {
  final String? tournamentId;
  const FixturesTab({super.key, this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchCubit, MatchState>(
      builder: (context, state) {
        if (state is MatchLoaded) {
          final futureMatches = state.matches
              .where((m) => m.status == match_model.MatchStatus.scheduled)
              .where(
                (m) => tournamentId == null || m.tournamentId == tournamentId,
              )
              .toList();
          futureMatches.sort((a, b) => a.startTime.compareTo(b.startTime));

          final Map<String, List<match_model.Match>> groupedMatches = {};
          for (var match in futureMatches) {
            final dateKey =
                "${match.startTime.year}-${match.startTime.month}-${match.startTime.day}";
            if (!groupedMatches.containsKey(dateKey)) {
              groupedMatches[dateKey] = [];
            }
            groupedMatches[dateKey]!.add(match);
          }

          if (groupedMatches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 48.sp, color: Colors.grey[800]),
                  SizedBox(height: 16.h),
                  Text(
                    'No upcoming matches',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: groupedMatches.length,
            itemBuilder: (context, index) {
              final dateKey = groupedMatches.keys.elementAt(index);
              final matches = groupedMatches[dateKey]!;
              final date = matches.first.startTime;

              final months = [
                'January',
                'February',
                'March',
                'April',
                'May',
                'June',
                'July',
                'August',
                'September',
                'October',
                'November',
                'December',
              ];
              final weekDays = [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday',
              ];

              final headerString =
                  "${weekDays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}";

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 4.w,
                    ),
                    child: Text(
                      headerString,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...matches.map((match) => MatchCard(match: match)),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        }
        if (state is MatchLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Center(child: Text('No fixtures data'));
      },
    );
  }
}
