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
    final dynamic data = json['data'];
    List<ExpenseData>? expenseList;

    if (data != null) {
      if (data is List) {
        expenseList = data.map((i) => ExpenseData.fromJson(i)).toList();
      } else if (data is Map<String, dynamic>) {
        expenseList = [ExpenseData.fromJson(data)]; // Wrap the single object in a list
      }
    }

    return ExpenseResponse(
      success: json['success'],
      data: expenseList,
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
  final String? paymentMethod;

  ExpenseData({
    this.id,
    this.description,
    this.amount,
    this.category,
    this.userId,
    this.date,
    this.notes,
    this.currency,
    this.paymentMethod
  });

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
        id: json['_id'],
        description: json['description'],
        amount: (json['amount'] as num?)?.toDouble(),
        category: json['category'],
        userId: json['user'],
        date: json['date'] != null ? DateTime.parse(json['date']) : null,
        notes: json['notes'],
        currency: json['currency'],
        paymentMethod: json['paymentMethod']
    );
  }

  // Method for serializing data when creating a new expense
  Map<String, dynamic> toJsonForCreate() {
    return {
      'description': description,
      'amount': amount,
      'category': category,
      'notes': notes,
      'currency': currency,
      'paymentMethod': paymentMethod,
      // 'user': userId, // Exclude
      // 'date': date?.toIso8601String(), // Exclude
      // '_id': id, // Exclude
    };
  }

  // Keep the original toJson for other purposes (e.g., updating) if needed
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'user': userId,
      'date': date?.toIso8601String(),
      'notes': notes,
      'currency':currency,
      'paymentMethod':paymentMethod
    };
  }
}
