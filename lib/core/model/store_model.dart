class Store {
  String? id;
  String? name;
  String? type;
  String? classification;
  String? country;
  String? state;
  String? lga;
  String? currency;
  String? owner;
  String? area;

  Store({
    this.id,
    this.name,
    this.type,
    this.classification,
    this.country,
    this.state,
    this.lga,
    this.currency,
    this.owner,
    this.area
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['_id'],
      name: json['name'],
      type: json['type'],
      classification: json['classification'],
      country: json['country'],
      state: json['state'],
      lga: json['lga'],
      currency: json['currency'],
      owner: json['owner'],
      area: json['area']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'classification': classification,
      'country': country,
      'state': state,
      'lga': lga,
      'currency': currency,
      'owner': owner,
      'area':area
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'type': type,
      'classification': classification,
      'country': country,
      'state': state,
      'lga': lga,
      'currency': currency,
    };
  }
}