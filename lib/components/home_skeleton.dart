import 'package:flutter/material.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  Widget _buildSkeletonBox({
    required double width,
    required double height,
    double borderRadius = 12,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSkeletonBox(width: screenWidth, height: 160),
            const SizedBox(height: 24),
            _buildSkeletonBox(width: screenWidth, height: 80),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildSkeletonBox(width: double.infinity, height: 180)),
                const SizedBox(width: 16),
                Expanded(child: _buildSkeletonBox(width: double.infinity, height: 180)),
              ],
            ),
            const SizedBox(height: 24),
            _buildSkeletonBox(width: screenWidth, height: 80),
          ],
        ),
      ),
    );
  }
} 