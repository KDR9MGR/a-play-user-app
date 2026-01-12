import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../location/providers/location_provider.dart';
import '../../subscription/provider/subscription_provider.dart';

class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    final hasSubscriptionAsync = ref.watch(hasActiveSubscriptionProvider);

    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      leadingWidth: 100,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: GestureDetector(
          onTap: () {
            context.go('/profile');
          },
          child: SvgPicture.asset(
            'assets/images/app_logo.svg',
          ),
        ),
      ),
      title: locationState.when(
        data: (location) => Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              context.push('/location');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      location?.city ?? 'Set Location',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Iconsax.arrow_down_1, size: 14),
                ],
              ),
            ),
          ),
        ),
        loading: () => Shimmer.fromColors(
          baseColor: Colors.grey,
          highlightColor: Colors.white,
          child: Row(
            children: [
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Loading...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        error: (error, stackTrace) => GestureDetector(
          onTap: () {
            ref.read(locationProvider.notifier).updateLocation();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.location_slash, size: 18),
              const SizedBox(width: 4),
              Text(
                'Retry',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      centerTitle: false,
      actions: [
        // Subscription button
        hasSubscriptionAsync.when(
          data: (hasSubscription) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: hasSubscription
                ? LinearGradient(
                    colors: [Colors.amber.shade600, Colors.orange.shade600],
                  )
                : LinearGradient(
                    colors: [Colors.purple.shade600, Colors.purple.shade800],
                  ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (hasSubscription) {
                    context.push('/subscription/history');
                  } else {
                    context.push('/subscription/plans');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasSubscription ? Iconsax.crown1 : Iconsax.card,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasSubscription ? 'Premium' : 'Go Pro',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          loading: () => const SizedBox(width: 20, height: 20),
          error: (_, __) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.purple.shade600, Colors.purple.shade800],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.push('/subscription/plans'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.card,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Go Pro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Iconsax.microphone_2),
          onPressed: () {
            context.push('/podcast');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
} 