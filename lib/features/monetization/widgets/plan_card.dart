import 'package:flutter/material.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final bool isPopular;
  final VoidCallback onSelect;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.features,
    this.isPopular = false,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPopular ? const Color(0xFF5D3FD3).withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? const Color(0xFF5D3FD3) : Colors.grey.shade300,
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF5D3FD3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text("MOST POPULAR", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              Text(price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5D3FD3))),
            ],
          ),
          const Divider(height: 24),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(f)),
              ],
            ),
          )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? const Color(0xFF5D3FD3) : Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text("Choose Plan"),
            ),
          )
        ],
      ),
    );
  }
}