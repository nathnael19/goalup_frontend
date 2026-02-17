import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/responsive.dart';

class CalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final screenWidth = MediaQuery.of(context).size.width;
        final targetOffset = (7 * 110.w) - (screenWidth / 2) + (110.w / 2);
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      height: 80.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 15,
        itemBuilder: (context, index) {
          final date = today.add(Duration(days: index - 7));
          final isSelected = date.isAtSameMomentAs(widget.selectedDate);
          final isToday = date.isAtSameMomentAs(today);

          String label;
          if (isToday) {
            label = 'Today';
          } else if (date.isAtSameMomentAs(
            today.subtract(const Duration(days: 1)),
          )) {
            label = 'Yesterday';
          } else if (date.isAtSameMomentAs(
            today.add(const Duration(days: 1)),
          )) {
            label = 'Tomorrow';
          } else {
            label = DateFormat('EEE d MMM').format(date);
          }

          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: Container(
              width: 110.w,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? Colors.green : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isToday
                          ? Colors.green[300]
                          : Colors.grey[500],
                      fontWeight: isSelected || isToday
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (isToday && !isSelected)
                    Positioned(
                      top: 4,
                      right: 12,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
