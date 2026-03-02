import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to track when welcome overlay is dismissed and should trigger tutorial
final welcomeOverlayDismissedProvider = StateProvider<bool>((ref) => false);