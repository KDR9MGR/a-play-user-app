import 'package:flutter/material.dart';
import 'package:a_play/features/profile/models/profile_model.dart';

class ProfileAvatar extends StatelessWidget {
  final ProfileModel profile;
  final double radius;
  final TextStyle? fallbackTextStyle;

  const ProfileAvatar({
    super.key,
    required this.profile,
    this.radius = 35,
    this.fallbackTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CircleAvatar(
      radius: radius,
      backgroundImage: profile.avatarUrl != null
          ? NetworkImage(profile.avatarUrl!)
          : null,
      child: profile.avatarUrl == null
          ? Text(
              profile.fullName!.substring(0, 1).toUpperCase(),
              style: fallbackTextStyle ?? theme.textTheme.headlineMedium,
            )
          : null,
    );
  }
} 