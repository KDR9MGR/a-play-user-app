import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class EventCardShimmer extends StatelessWidget {
  const EventCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 12),
          const ShimmerLoading(
            width: 150,
            height: 20,
            margin: EdgeInsets.only(bottom: 8),
          ),
          const ShimmerLoading(
            width: double.infinity,
            height: 16,
            margin: EdgeInsets.only(bottom: 4),
          ),
          const ShimmerLoading(
            width: 100,
            height: 16,
          ),
        ],
      ),
    );
  }
}

class EventListShimmer extends StatelessWidget {
  final int itemCount;

  const EventListShimmer({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) => const EventCardShimmer(),
    );
  }
} 