import 'package:flutter/material.dart';

enum AppDestination {
  home,
  earnings,
  settings, 
}

extension AppDestinationX on AppDestination {
  String get label {
    switch (this) {
      case AppDestination.home:
        return 'Home';        
      case AppDestination.earnings:
        return 'Earnings';
      case AppDestination.settings:
        return 'Settings';
    }
  }

  IconData get icon {
    switch (this) {
      case AppDestination.home:
        return Icons.home;
      case AppDestination.earnings:
        return Icons.trending_up;
      case AppDestination.settings:
        return Icons.settings;
    }
  }
}
