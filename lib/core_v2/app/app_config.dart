import '../branding/brand_colors.dart';
import '../theme/color_tokens.dart';

class AppConfig {
  final BrandColors brand;
  final ColorTokens tokens;

  const AppConfig({
    required this.brand,
    required this.tokens,
  });

  /// Default app configuration (no partner branding)
  factory AppConfig.defaultConfig() {
    return const AppConfig(
      brand: BrandColors.defaultBrand,
      tokens: ColorTokens.light,
    );
  }
}
