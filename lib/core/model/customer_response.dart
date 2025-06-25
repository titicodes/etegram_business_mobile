import 'package:equatable/equatable.dart';

/// Used when response returns a list of customers
class CustomerResponse extends Equatable {
  final bool? success;
  final List<CustomerData>? data;
  final String? message;
  final int? total;

  const CustomerResponse({
    this.success,
    this.data,
    this.message,
    this.total,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List<dynamic>)
          .map((e) => CustomerData.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
      message: json['message'] ?? '',
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.map((e) => e.toJson()).toList(),
    'message': message,
    'total': total,
  };

  @override
  List<Object?> get props => [success, data, message, total];
}

/// Used when response returns a single customer (e.g. create or fetch one)
class SingleCustomerResponse extends Equatable {
  final bool? success;
  final CustomerData? data;
  final String? message;

  const SingleCustomerResponse({
    this.success,
    this.data,
    this.message,
  });

  factory SingleCustomerResponse.fromJson(Map<String, dynamic> json) {
    return SingleCustomerResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? CustomerData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.toJson(),
    'message': message,
  };

  @override
  List<Object?> get props => [success, data, message];
}

class CustomerData extends Equatable {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final String? storeId;
  final String? birthday;
  final String? extraPhone;
  final String? extraDetails;
  final String? country;
  final String? state;
  final String? lga;
  final String? area;

  const CustomerData({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.address,
    this.storeId,
    this.birthday,
    this.extraPhone,
    this.extraDetails,
    this.country,
    this.state,
    this.lga,
    this.area,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      id: json['_id']?.toString(),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      storeId: json['store']?.toString() ?? '',
      birthday: json['birthday']?.toString(),
      extraPhone: json['extraPhone'],
      extraDetails: json['extraDetails'],
      country: json['country'],
      state: json['state'],
      lga: json['lga'],
      area: json['area'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phoneNumber': phoneNumber,
    'address': address,
    'store': storeId,
    'birthday': birthday,
    'extraPhone': extraPhone,
    'extraDetails': extraDetails,
    'country': country,
    'state': state,
    'lga': lga,
    'area': area,
  };

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phoneNumber,
    address,
    storeId,
    birthday,
    extraPhone,
    extraDetails,
    country,
    state,
    lga,
    area,
  ];
}
