import 'package:a_play/features/profile/widgets/premium_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:a_play/features/profile/models/profile_model.dart';
import 'package:a_play/features/profile/widgets/profile_avatar.dart';
import 'package:a_play/features/profile/widgets/profile_menu_item.dart';
import 'package:a_play/features/booking/screens/my_tickets_screen.dart';

class ProfileContent extends StatelessWidget {
  final ProfileModel profile;

  const ProfileContent({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Row(
          children: [
            ProfileAvatar(profile: profile),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.fullName!,
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),

                      Text(
                        profile.phone ?? 'No Phone',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      //Premium Badge
                      if (profile.isPremium) const PremiumBadge(),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      context.push('/profile/edit');
                    },
                    icon: const Icon(Iconsax.edit),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ProfileMenuItem(
                icon: Iconsax.ticket,
                title: 'My Tickets',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyTicketsScreen(),
                    ),
                  );
                },
              ),
              ProfileMenuItem(
                icon: Iconsax.notification,
                title: 'Notifications',
                onTap: () {
                  // TODO: Implement notifications
                },
              ),
              ProfileMenuItem(
                icon: Iconsax.security,
                title: 'Privacy & Security',
                onTap: () {
                  // TODO: Implement privacy & security
                },
              ),
              ProfileMenuItem(
                icon: Iconsax.setting_2,
                title: 'Settings',
                onTap: () {
                  // TODO: Implement settings
                },
              ),
              ProfileMenuItem(
                icon: Iconsax.info_circle,
                title: 'About',
                onTap: () {
                  // TODO: Implement about
                },
              ),
              //Logout Button
              ProfileMenuItem(
                icon: Iconsax.logout,
                title: 'Logout',
                onTap: () {
                  // TODO: Implement logout
                },
              ),
              const SizedBox(height: 32),
              //App Logo and Version
              Row(
                children: [
                  SvgPicture.asset('assets/images/app_logo.svg',
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 32,
                      height: 32),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'v1.0.0',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
