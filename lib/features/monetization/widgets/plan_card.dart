import 'package:flutter/material.dart';
import '../models/plan_data.dart';

class PlanCard extends StatelessWidget {
  final PlanPricing plan;
  final bool isAnnual;
  final bool isCurrent;
  final bool isProcessing;
  final VoidCallback? onUpgrade;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isAnnual,
    required this.isCurrent,
    this.isProcessing = false,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = plan.monthlyNaira > 0;
    final isPopular = plan.badge.isNotEmpty;
    final color = plan.accentColor;
    final priceLabel = isAnnual ? plan.yearlyLabel() : plan.monthlyLabel();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent
              ? Colors.green
              : isPopular
                  ? color
                  : Colors.grey.shade300,
          width: isCurrent || isPopular ? 2.5 : 1,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                )
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Gradient Header ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge row
                        if (isCurrent || isPopular)
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? Colors.green
                                  : Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isCurrent ? '✓  YOUR CURRENT PLAN' : plan.badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        Text(
                          plan.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          plan.subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        priceLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isAnnual && isPaid)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '2 months FREE',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // --- Feature highlights ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...plan.highlights.map((h) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 17, color: color),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(h,
                                    style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 14),

                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    child: isCurrent
                        ? OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.check),
                            label: const Text('Active Plan'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          )
                        : plan.monthlyNaira == 0
                            ? OutlinedButton(
                                onPressed: null,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                                child: const Text('Free Plan'),
                              )
                            : ElevatedButton.icon(
                                onPressed:
                                    isProcessing ? null : onUpgrade,
                                icon: isProcessing
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : const Icon(Icons.arrow_upward,
                                        size: 16),
                                label: Text(
                                    'Upgrade to ${plan.title}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}