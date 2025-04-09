class ExpenseResponse {
  final bool success;
  final List<ExpenseData>? data;
  final String? message;

  ExpenseResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory ExpenseResponse.fromJson(Map<String, dynamic> json) {
    return ExpenseResponse(
      success: json['success'],
      data: json['data'] != null
          ? (json['data'] as List).map((i) => ExpenseData.fromJson(i)).toList()
          : null,
      message: json['message'],
    );
  }
}

class ExpenseData {
  final String? id;
  final String? description;
  final double? amount;
  final String? category;
  final String? userId;
  final DateTime? date;
  final String? notes;
  final String? currency;

  ExpenseData({
    this.id,
    this.description,
    this.amount,
    this.category,
    this.userId,
    this.date,
    this.notes,
    this.currency,
  });

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      id: json['_id'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      userId: json['user'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      currency: json['currency']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'user': userId,
      'date': date?.toIso8601String(),
      'notes': notes,
      'currency':currency
    };
  }
}
