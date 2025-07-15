class SubscriptionModel {
  final String? id;
  final String status;
  final bool isActive;
  final String? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? trialEndDate;

  SubscriptionModel({
    this.id,
    required this.status,
    required this.isActive,
    this.type,
    this.startDate,
    this.endDate,
    this.trialEndDate,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['_id']?.toString(),
      status: json['status']?.toString() ?? 'NONE',
      isActive: json['isActive'] ?? false,
      type: json['type']?.toString(),
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      trialEndDate: json['trialEndDate'] != null ? DateTime.tryParse(json['trialEndDate']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'status': status,
    'isActive': isActive,
    'type': type,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'trialEndDate': trialEndDate?.toIso8601String(),
  };
}