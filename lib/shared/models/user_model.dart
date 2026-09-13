class UserModel {
  final int id;

  final String name;

  final String email;

  final String role;

  final String? country;

  final String? location;

  final bool verified;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.country,
    this.location,
    required this.verified,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      country: json['country'] as String?,
      location: json['location'] as String?,
      verified: json['verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'country': country,
      'location': location,
      'verified': verified,
    };
  }

  bool get isFarmer => role == 'FARMER';

  bool get isConsumer => role == 'CONSUMER';

  bool get isInternationalBuyer => role == 'INTERNATIONAL_BUYER';

  bool get isAdmin => role == 'ADMIN';
}
