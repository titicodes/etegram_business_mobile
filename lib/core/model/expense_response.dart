class ExpenseData {
  String? id;
  String? description;
  double? amount;
  String? category;
  String? userId;
  String? storeId;
  String? currency;
  String? paymentMethod;
  String? notes;
  DateTime? date;
  DateTime? createdAt;
  DateTime? updatedAt;

  ExpenseData({
    this.id,
    this.description,
    this.amount,
    this.category,
    this.userId,
    this.storeId,
    this.currency,
    this.paymentMethod,
    this.notes,
    this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      id: json['_id']?.toString(),
      description: json['description']?.toString(),
      amount: double.tryParse(json['amount']?.toString() ?? '0'),
      category: json['category']?.toString(),
      userId: json['user']?.toString(),
      storeId: json['store']?.toString(),
      currency: json['currency']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      notes: json['notes']?.toString(),
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (storeId != null) 'store': storeId,
      if (currency != null) 'currency': currency,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (notes != null) 'notes': notes,
      if (date != null) 'date': date!.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (storeId != null) 'storeId': storeId,
      if (currency != null) 'currency': currency,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (notes != null) 'notes': notes,
      if (date != null) 'date': date!.toIso8601String(),
    };
  }

  ExpenseData copyWith({
    String? id,
    String? description,
    double? amount,
    String? category,
    String? userId,
    String? storeId,
    String? currency,
    String? paymentMethod,
    String? notes,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseData(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      storeId: storeId ?? this.storeId,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
