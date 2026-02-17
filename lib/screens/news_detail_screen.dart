import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/news.dart';

import '../services/api_service.dart';
import '../utils/responsive.dart';

class NewsDetailScreen extends StatelessWidget {
  final News news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiService.getImageFullUrl(news.imageUrl);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Static Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.30,
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: Icon(
                        Icons.broken_image,
                        size: 64.sp,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(color: Colors.grey[900]),
          ),

          // Scrollable Content Layer
          SingleChildScrollView(
            child: Column(
              children: [
                // Transparent Spacer to reveal the image
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),

                // Content Container that overlaps the image
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF121212), // Match Scaffold background
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Badge with Gradient
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF7043), Color(0xFFE53935)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: Text(
                          news.category.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        news.title,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date & Reporter
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16.sp,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            DateFormat('MMM d, yyyy').format(news.date),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(width: 24.w),
                          Icon(
                            Icons.person_outline,
                            size: 16.sp,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            news.reporterName,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Summary
                      Text(
                        news.description,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[400],
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Full Content
                      Text(
                        news.content ??
                            'Full article content goes here. This is a demo article showcasing a premium layout with smooth typography, rounded cards, and interactive features.Full article content goes here. This is a demo article showcasing a premium layout with smooth typography, rounded cards, and interactive features.Full article content goes here. This is a demo article showcasing a premium layout with smooth typography, rounded cards, and interactive features.Full article content goes here. This is a demo article showcasing a premium layout with smooth typography, rounded cards, and interactive features.Full article content goes here. This is a demo article showcasing a premium layout with smooth typography, rounded cards, and interactive features.Full article content goes here. This is a demo article showcasing a premium layout with smooth typography, rounded cards, and interactive features.',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey[500],
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 48.h), // Padding at bottom
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Custom Back Button Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
