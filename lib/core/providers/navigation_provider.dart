import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage the global navigation state (active tab index)
final navigationProvider = StateProvider<int>((ref) => 0);

/// Constants for tab indices to avoid magic numbers
class AppTabs {
  static const int dashboard = 0;
  static const int jobs = 1;
  static const int customers = 2;
  static const int community = 3;
  static const int settings = 4;
}
