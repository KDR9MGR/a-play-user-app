import 'package:a_play/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/features/location/screens/select_location_screen.dart';
import 'package:a_play/core/providers/location_provider.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 24);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAppLogo(context),
          _buildRightSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildAppLogo(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: SvgPicture.asset(
        'assets/images/app_logo.svg',
        height: 35,
      ),
    );
  }

  Widget _buildRightSection(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _buildLocationButton(context, ref),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildLocationButton(BuildContext context, WidgetRef ref) {
    final selectedLocation = ref.watch(selectedLocationProvider);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SelectLocationScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),
            Text(
              selectedLocation?.locality ?? 'Select Location',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Iconsax.arrow_down_1,
              color: Colors.white,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Iconsax.microphone_2,
        color: Colors.white,
        size: 24,
      ),
      onPressed: () => context.push('/podcast'),
    );
  }
}
