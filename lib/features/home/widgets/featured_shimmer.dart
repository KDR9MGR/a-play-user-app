//Featured Shimmer
import 'package:a_play/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FeaturedShimmer extends StatelessWidget {
  const FeaturedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Title Loading   
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Shimmer.fromColors(
            baseColor: AppColors.darkGrey,
            highlightColor: AppColors.white.withOpacity(0.5),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        //Carousel Loading
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => Shimmer.fromColors(
              baseColor: AppColors.darkGrey,
              highlightColor: AppColors.white.withOpacity(0.5),
              child: const SizedBox(
                width: 200,
                height: 200,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
