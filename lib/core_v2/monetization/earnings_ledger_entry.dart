class EarningsLedgerEntry {
  final int year;
  final int month;
  final int referralCount;
  final double amountUsd;
  final double rolloverBalanceUsd;
  final bool isPayable;
  final bool isSettled;
  final DateTime? settledAt;
  final bool isLocked;


  const EarningsLedgerEntry({
  required this.year,
  required this.month,
  required this.referralCount,
  required this.amountUsd,
  required this.rolloverBalanceUsd,
  required this.isPayable,
  required this.isSettled,
  required this.isLocked,
  this.settledAt,
});

bool get isCurrentMonth {
  final now = DateTime.now();
  return year == now.year && month == now.month;
}


  EarningsLedgerEntry settle(DateTime time) {
    return EarningsLedgerEntry(
      year: year,
      month: month,
      referralCount: referralCount,
      amountUsd: amountUsd,
      rolloverBalanceUsd: 0,
      isPayable: false,
      isSettled: true,
      settledAt: time,
      isLocked: isLocked,
    );
  }

  Map<String, dynamic> toJson() => {
        'year': year,
        'month': month,
        'referralCount': referralCount,
        'amountUsd': amountUsd,
        'rolloverBalanceUsd': rolloverBalanceUsd,
        'isPayable': isPayable,
        'isSettled': isSettled,
        'settledAt': settledAt?.toIso8601String(),
      };

  factory EarningsLedgerEntry.fromJson(Map<String, dynamic> json) {
    return EarningsLedgerEntry(
      year: json['year'],
      month: json['month'],
      referralCount: json['referralCount'],
      amountUsd: (json['amountUsd'] as num).toDouble(),
      rolloverBalanceUsd:
          (json['rolloverBalanceUsd'] as num?)?.toDouble() ?? 0,
      isPayable: json['isPayable'] ?? false,
      isSettled: json['isSettled'] ?? false,
      settledAt: json['settledAt'] != null
          ? DateTime.parse(json['settledAt'])
          : null,          
      isLocked: json['isLocked'] ?? false,
    );
  }
  String get label {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${months[month - 1]} $year';
}
  
}
