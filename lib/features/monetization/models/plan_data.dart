import 'package:flutter/material.dart';

/// Feature comparison row data for the upgrade screen.
class PlanFeature {
  final String label;
  final bool freemium;
  final bool standard;
  final bool premium;
  final String? note; // Optional extra detail shown as a subtitle

  const PlanFeature({
    required this.label,
    this.freemium = false,
    this.standard = false,
    this.premium = false,
    this.note,
  });
}

/// All features compared across tiers.
const List<PlanFeature> kPlanFeatures = [
  PlanFeature(label: 'Up to 20 customers', freemium: true, standard: true, premium: true),
  PlanFeature(label: 'Unlimited customers', freemium: false, standard: true, premium: true),
  PlanFeature(label: 'Daily ad gate', freemium: true, standard: false, premium: false),
  PlanFeature(label: 'No video ads', freemium: false, standard: true, premium: true),
  PlanFeature(label: 'Job & order tracking', freemium: true, standard: true, premium: true),
  PlanFeature(label: 'Customer measurements', freemium: true, standard: true, premium: true),
  PlanFeature(label: 'PDF invoices & quotations', freemium: false, standard: true, premium: true),
  PlanFeature(label: 'Cloud sync & backup', freemium: false, standard: true, premium: true),
  PlanFeature(label: 'Shop branding & logo', freemium: false, standard: true, premium: true),
  PlanFeature(label: 'Referral & partner system', freemium: false, standard: false, premium: true),
  PlanFeature(label: '40% commission – first month', freemium: false, standard: false, premium: true),
  PlanFeature(label: '20% recurring commissions', freemium: false, standard: false, premium: true),
  PlanFeature(label: 'Passive income dashboard', freemium: false, standard: false, premium: true),
];

/// Pricing for each plan.
class PlanPricing {
  final String title;
  final String subtitle;
  final int monthlyNaira;
  final int yearlyNaira;
  final Color accentColor;
  final String badge;
  final Color badgeColor;
  final List<String> highlights;

  const PlanPricing({
    required this.title,
    required this.subtitle,
    required this.monthlyNaira,
    required this.yearlyNaira,
    required this.accentColor,
    this.badge = '',
    this.badgeColor = const Color(0xFF607D8B),
    required this.highlights,
  });

  String monthlyLabel() => monthlyNaira == 0 ? 'Free' : '₦${_fmt(monthlyNaira)}/mo';
  String yearlyLabel() => yearlyNaira == 0 ? 'Free' : '₦${_fmt(yearlyNaira)}/yr';
  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
}

const List<PlanPricing> kPlans = [
  PlanPricing(
    title: 'Freemium',
    subtitle: 'Get started for free',
    monthlyNaira: 0,
    yearlyNaira: 0,
    accentColor: Color(0xFF607D8B),
    badge: 'FREE',
    badgeColor: Color(0xFF607D8B),
    highlights: [
      'Up to 20 customers',
      'Basic job tracking',
      'Watch ads to unlock more',
    ],
  ),
  PlanPricing(
    title: 'Standard',
    subtitle: 'For growing tailors',
    monthlyNaira: 3000,
    yearlyNaira: 30000,
    accentColor: Color(0xFF1E78D2),
    badge: 'MOST POPULAR',
    badgeColor: Color(0xFF1E78D2),
    highlights: [
      'Unlimited customers',
      'No ads ever',
      'PDF invoices & cloud backup',
    ],
  ),
  PlanPricing(
    title: 'Premium',
    subtitle: 'Earn while you work',
    monthlyNaira: 5000,
    yearlyNaira: 50000,
    accentColor: Color(0xFFF58220),
    badge: 'BEST VALUE',
    badgeColor: Color(0xFFE65100),
    highlights: [
      'Everything in Standard',
      'Referral commissions (up to 40%)',
      'Passive income dashboard',
    ],
  ),
];
