class User {
  final String id;
  final String? email;
  final String? phone;
  final String firstName;
  final String lastName;
  final String role;
  final bool isVerified;
  final String? profileImageUrl;
  final String? city;
  final String? country;

  User({
    required this.id,
    this.email,
    this.phone,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isVerified,
    this.profileImageUrl,
    this.city,
    this.country,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String? ?? json['phoneNumber'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: json['role'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
      profileImageUrl: json['profileImageUrl'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'isVerified': isVerified,
      'profileImageUrl': profileImageUrl,
      'city': city,
      'country': country,
    };
  }

  String get fullName => '$firstName $lastName';
}
