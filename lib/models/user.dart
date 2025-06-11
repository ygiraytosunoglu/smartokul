class User {
  final String tckn;
  final String name;
  final String surname;
  final String? email;
  final String? phone;

  User({
    required this.tckn,
    required this.name,
    required this.surname,
    this.email,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      tckn: json['tckn'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tckn': tckn,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
    };
  }
} 