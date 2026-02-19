import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/responsive.dart';

class CalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final List<DateTime> availableDates;
  final Function(DateTime) onDateSelected;

  const CalendarStrip({
    super.key,
    required this.selectedDate,
    required this.availableDates,
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(CalendarStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.availableDates != widget.availableDates) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _scrollToSelected() {
    if (_scrollController.hasClients && widget.availableDates.isNotEmpty) {
      final index = widget.availableDates.indexWhere(
        (d) =>
            d.year == widget.selectedDate.year &&
            d.month == widget.selectedDate.month &&
            d.day == widget.selectedDate.day,
      );
      if (index != -1) {
        final screenWidth = MediaQuery.of(context).size.width;
        final targetOffset = (index * 100.w) - (screenWidth / 2) + (100.w / 2);
        _scrollController.animateTo(
          targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.availableDates.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      height: 80.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.availableDates.length,
        itemBuilder: (context, index) {
          final date = widget.availableDates[index];
          final isSelected =
              date.year == widget.selectedDate.year &&
              date.month == widget.selectedDate.month &&
              date.day == widget.selectedDate.day;
          final isToday =
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          String label;
          if (isToday) {
            label = 'Today';
          } else if (date.year == today.year &&
              date.month == today.month &&
              date.day == today.day - 1) {
            label = 'Yesterday';
          } else if (date.year == today.year &&
              date.month == today.month &&
              date.day == today.day + 1) {
            label = 'Tomorrow';
          } else {
            label = DateFormat('EEE d MMM').format(date);
          }

          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: Container(
              width: 100.w,
              padding: EdgeInsets.symmetric(vertical: 5.h),
              decoration: const BoxDecoration(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 30.w,
                        height: 3.h,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ),
                    ),
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
                      fontSize: 12.sp,
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
