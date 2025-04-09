class Supplier {
  String? id;
  String businessName;
  String contactName;
  String email;
  String phoneNumber;
  String currency;
  String accountDetails;
  String address;
  String country;
  String state;
  String lga;
  String area;
  String? supplierType; // Optional field
  String? extraMobile;   // Optional field

  Supplier({
    this.id,
    required this.businessName,
    required this.contactName,
    required this.email,
    required this.phoneNumber,
    required this.currency,
    required this.accountDetails,
    required this.address,
    required this.country,
    required this.state,
    required this.lga,
    required this.area,
    this.supplierType,
    this.extraMobile,
  });

  // Factory method to create a Supplier instance from JSON
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['_id']?.toString(),
      businessName: json['businessName']?.toString() ?? '',
      contactName: json['contactName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      accountDetails: json['accountDetails']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      lga: json['lga']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      supplierType: json['supplierType']?.toString(),
      extraMobile: json['extraMobile']?.toString(),
    );
  }


  // Method to convert a Supplier instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'contactName': contactName,
      'email': email,
      'phoneNumber': phoneNumber,
      'currency': currency,
      'accountDetails': accountDetails,
      'address': address,
      'country': country,
      'state': state,
      'lga': lga,
      'area': area,
      if (supplierType != null) 'supplierType': supplierType,
      if (extraMobile != null) 'extraMobile': extraMobile,
    };
  }
}
