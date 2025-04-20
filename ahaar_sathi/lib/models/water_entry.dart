class WaterEntry {
  final String id;
  final int amount; // in milliliters
  final DateTime timestamp;

  WaterEntry({
    required this.id,
    required this.amount,
    required this.timestamp,
  });

  factory WaterEntry.fromJson(Map<String, dynamic> json) {
    return WaterEntry(
      id: json['id'],
      amount: json['amount'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 