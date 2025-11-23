import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Reusable shimmer loading widget for consistent loading states across the app
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShimmerShape shape;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = ShimmerShape.rectangle,
  });

  const ShimmerLoading.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = 100,
        shape = ShimmerShape.circle;

  const ShimmerLoading.rectangle({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  }) : shape = ShimmerShape.rectangle;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1A1A1A),
      highlightColor: const Color(0xFF2A2A2A),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: shape == ShimmerShape.circle
              ? BorderRadius.circular(borderRadius)
              : BorderRadius.circular(borderRadius),
          shape: shape == ShimmerShape.circle ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }
}

enum ShimmerShape {
  rectangle,
  circle,
}

/// Shimmer loading for subscription plan cards
class SubscriptionPlanShimmer extends StatelessWidget {
  const SubscriptionPlanShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF252525)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerLoading.circular(size: 52),
                const ShimmerLoading.rectangle(width: 80, height: 32, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 24),

            // Plan name
            const ShimmerLoading.rectangle(width: 150, height: 32, borderRadius: 8),
            const SizedBox(height: 8),

            // Description
            const ShimmerLoading.rectangle(width: double.infinity, height: 40, borderRadius: 8),
            const SizedBox(height: 32),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading.rectangle(width: 40, height: 24, borderRadius: 6),
                const SizedBox(width: 8),
                const ShimmerLoading.rectangle(width: 120, height: 56, borderRadius: 8),
              ],
            ),
            const SizedBox(height: 32),

            // Divider shimmer
            ShimmerLoading.rectangle(
              width: double.infinity,
              height: 1,
              borderRadius: 0,
            ),
            const SizedBox(height: 24),

            // "What's included" text
            const ShimmerLoading.rectangle(width: 140, height: 12, borderRadius: 4),
            const SizedBox(height: 16),

            // Features list
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ShimmerLoading.circular(size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: ShimmerLoading.rectangle(width: double.infinity, height: 16, borderRadius: 4),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Button
            const ShimmerLoading.rectangle(
              width: double.infinity,
              height: 56,
              borderRadius: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading for active subscription card
class ActiveSubscriptionShimmer extends StatelessWidget {
  const ActiveSubscriptionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF252525)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              ShimmerLoading.circular(size: 40),
              const SizedBox(width: 12),
              const ShimmerLoading.rectangle(width: 100, height: 16, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 20),

          // Plan name
          const ShimmerLoading.rectangle(width: 150, height: 28, borderRadius: 8),
          const SizedBox(height: 8),

          // Valid until
          const ShimmerLoading.rectangle(width: 180, height: 14, borderRadius: 6),
          const SizedBox(height: 20),

          // Amount and button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLoading.rectangle(width: 60, height: 12, borderRadius: 4),
                  const SizedBox(height: 4),
                  const ShimmerLoading.rectangle(width: 100, height: 20, borderRadius: 6),
                ],
              ),
              const ShimmerLoading.rectangle(width: 120, height: 40, borderRadius: 12),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading for list items
class ListItemShimmer extends StatelessWidget {
  final int itemCount;

  const ListItemShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ShimmerLoading.circular(size: 56),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading.rectangle(
                    width: double.infinity,
                    height: 16,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 8),
                  ShimmerLoading.rectangle(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 12,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading for grid items
class GridItemShimmer extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const GridItemShimmer({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ShimmerLoading.rectangle(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 16,
            ),
          ),
          const SizedBox(height: 8),
          const ShimmerLoading.rectangle(width: double.infinity, height: 16, borderRadius: 4),
          const SizedBox(height: 4),
          ShimmerLoading.rectangle(
            width: MediaQuery.of(context).size.width * 0.3,
            height: 12,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}
