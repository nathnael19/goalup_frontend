import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class MatchTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> events;

  const MatchTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          'No events recorded',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final bool isHome = event['team'] == 'home';

        return IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: isHome
                    ? _buildEventContent(event, isHome: true)
                    : const SizedBox(),
              ),
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isHome
                          ? Theme.of(context).colorScheme.primary
                          : (event['team'] == 'away'
                                ? Colors.grey[700]
                                : Colors.transparent),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: index == events.length - 1
                        ? const SizedBox()
                        : VerticalDivider(
                            width: 2,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                  ),
                ],
              ),
              Expanded(
                child: !isHome
                    ? _buildEventContent(event, isHome: false)
                    : const SizedBox(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventContent(
    Map<String, dynamic> event, {
    required bool isHome,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: isHome ? 0 : 16.w,
        right: isHome ? 16.w : 0,
        bottom: 24.h,
      ),
      child: Column(
        crossAxisAlignment: isHome
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isHome
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!isHome) _buildEventIcon(event['type'] as String),
              if (!isHome) SizedBox(width: 8.w),
              Text(
                "${event['min']}'",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp),
              ),
              if (isHome) SizedBox(width: 8.w),
              if (isHome) _buildEventIcon(event['type'] as String),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "${event['player']} ${event['detail']}",
            textAlign: isHome ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventIcon(String type) {
    switch (type) {
      case 'goal':
        return Icon(
          Icons.sports_soccer,
          size: 16.sp,
          color: Colors.greenAccent,
        );
      case 'yellow_card':
        return Container(
          width: 10.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(2.w),
          ),
        );
      case 'red_card':
        return Container(
          width: 10.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(2.w),
          ),
        );
      case 'sub':
        return Icon(Icons.sync_alt, size: 16.sp, color: Colors.blueAccent);
      default:
        return Icon(Icons.info_outline, size: 16.sp);
    }
  }
}
