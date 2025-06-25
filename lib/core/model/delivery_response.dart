class DeliveryData {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? extraPhone;
  String? estate;
  String? country;
  String? state;
  String? city;
  String? area;
  String? supplierType;
  String? extraDetails;
  String? storeId;
  String? userId;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  DeliveryData({
    this.id,
     this.firstName,
     this.lastName,
     this.email,
     this.phoneNumber,
    this.extraPhone,
     this.estate,
     this.country,
     this.state,
     this.city,
     this.area,
     this.supplierType,
    this.extraDetails,
     this.storeId,
    this.userId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory DeliveryData.fromJson(Map<String, dynamic> json) {
    return DeliveryData(
      id: json['_id']?.toString(),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      extraPhone: json['extraPhone'],
      estate: json['estate'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      area: json['area'] ?? '',
      supplierType: json['supplierType'] ?? '',
      extraDetails: json['extraDetails'],
      storeId: json['store']?.toString() ?? '',
      userId: json['user']?.toString(),
      status: json['status'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      if (extraPhone != null) 'extraPhone': extraPhone,
      'estate': estate,
      'country': country,
      'state': state,
      'city': city,
      'area': area,
      'supplierType': supplierType,
      if (extraDetails != null) 'extraDetails': extraDetails,
      'storeId': storeId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      if (extraPhone != null) 'extraPhone': extraPhone,
      'estate': estate,
      'country': country,
      'state': state,
      'city': city,
      'area': area,
      'supplierType': supplierType,
      if (extraDetails != null) 'extraDetails': extraDetails,
      'storeId': storeId,
      if (status != null) 'status': status,
    };
  }
}

class DeliveryTransactionData {
  String? id;
  String orderId;
  String storeId;
  String? supplierId;
  List<Map<String, dynamic>> items;
  String? notes;
  String? status;
  String? userId;
  DateTime? createdAt;
  DateTime? updatedAt;

  DeliveryTransactionData({
    this.id,
    required this.orderId,
    required this.storeId,
    this.supplierId,
    required this.items,
    this.notes,
    this.status,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory DeliveryTransactionData.fromJson(Map<String, dynamic> json) {
    return DeliveryTransactionData(
      id: json['_id']?.toString(),
      orderId: json['orderId'] ?? '',
      storeId: json['store']?.toString() ?? '',
      supplierId: json['supplierId']?.toString(),
      items:
          (json['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
      notes: json['notes'],
      status: json['status'],
      userId: json['user']?.toString(),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'orderId': orderId,
      'storeId': storeId,
      if (supplierId != null) 'supplierId': supplierId,
      'items': items,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
    };
  }
}
