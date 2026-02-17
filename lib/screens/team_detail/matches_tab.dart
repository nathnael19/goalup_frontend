import 'package:flutter/material.dart';
import '../../models/match.dart' as model;
import '../../widgets/match_card.dart';
import '../../utils/responsive.dart';

class MatchesTab extends StatelessWidget {
  final List<model.Match>? matches;

  const MatchesTab({super.key, this.matches});

  @override
  Widget build(BuildContext context) {
    if (matches != null && matches!.isNotEmpty) {
      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: matches!.length,
        itemBuilder: (context, index) {
          final match = matches![index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: MatchCard(match: match),
          );
        },
      );
    } else {
      return Center(
        child: Text(
          'No matches found',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      );
    }
  }
}
