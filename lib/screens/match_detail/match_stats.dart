import 'package:flutter/material.dart';

class MatchStats extends StatelessWidget {
  const MatchStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'Match stats not available',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
