import 'package:hive_ce/hive.dart';

@HiveType(typeId: 4)
class SyncAction {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String actionType; // 'CREATE', 'UPDATE', 'DELETE'
  @HiveField(2)
  final String endpoint;   // 'jobs', 'customers', etc.
  @HiveField(3)
  final Map<String, dynamic> payload;
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  final int retryCount;
  @HiveField(6)
  final String? error;

  SyncAction({
    required this.id,
    required this.actionType,
    required this.endpoint,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.error,
  });

  factory SyncAction.fromJson(Map<String, dynamic> json) => SyncAction(
        id: json['id'] as String,
        actionType: json['actionType'] as String,
        endpoint: json['endpoint'] as String,
        payload: json['payload'] as Map<String, dynamic>,
        createdAt: DateTime.parse(json['createdAt'] as String),
        retryCount: json['retryCount'] as int? ?? 0,
        error: json['error'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'actionType': actionType,
        'endpoint': endpoint,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
        'error': error,
      };

  SyncAction copyWith({
    String? id,
    String? actionType,
    String? endpoint,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    int? retryCount,
    String? error,
  }) {
    return SyncAction(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      endpoint: endpoint ?? this.endpoint,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      error: error ?? this.error,
    );
  }

  static const String actionCreate = 'CREATE';
  static const String actionUpdate = 'UPDATE';
  static const String actionDelete = 'DELETE';
}
