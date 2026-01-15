class PayoutRequest {
  final DateTime requestedAt;
  final double amountUsd;
  final bool isPaid;
  final DateTime? paidAt;

  const PayoutRequest({
    required this.requestedAt,
    required this.amountUsd,
    this.isPaid = false,
    this.paidAt,
  });

  PayoutRequest markPaid(DateTime time) {
    return PayoutRequest(
      requestedAt: requestedAt,
      amountUsd: amountUsd,
      isPaid: true,
      paidAt: time,
    );
  }

  Map<String, dynamic> toJson() => {
        'requestedAt': requestedAt.toIso8601String(),
        'amountUsd': amountUsd,
        'isPaid': isPaid,
        'paidAt': paidAt?.toIso8601String(),
      };

  factory PayoutRequest.fromJson(Map<String, dynamic> json) {
    return PayoutRequest(
      requestedAt: DateTime.parse(json['requestedAt']),
      amountUsd: json['amountUsd'],
      isPaid: json['isPaid'] ?? false,
      paidAt:
          json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }
}
