import 'package:flutter/material.dart';
import '../branding/brand_colors.dart';
import 'color_tokens.dart';
import 'app_theme.dart';

enum ThemeModeType { light, dark }

class ThemeController extends ChangeNotifier {
  ThemeModeType _mode = ThemeModeType.light;
  BrandColors _brand = BrandColors.defaultBrand;

  ThemeModeType get mode => _mode;
  BrandColors get brand => _brand;

  void toggleDarkMode() {
    _mode = _mode == ThemeModeType.light
        ? ThemeModeType.dark
        : ThemeModeType.light;
    notifyListeners();
  }

  void applyBrand(BrandColors brand) {
    _brand = brand;
    notifyListeners();
  }

  ThemeData get theme {
    return AppTheme.build(
      brand: _brand,
      tokens: _mode == ThemeModeType.light
          ? ColorTokens.light
          : ColorTokens.dark,
      brightness:
          _mode == ThemeModeType.light ? Brightness.light : Brightness.dark,
    );
  }
}
