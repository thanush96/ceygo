import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String nationality;
  final String idType; // 'NIC' or 'Passport'
  final String nic;
  final String licenseNo;
  final String? profilePic;
  final String role; // 'renter', 'owner', 'admin'
  final String verificationStatus; // 'pending', 'approved', 'rejected'
  final String status; // 'active', 'banned'
  final String? reason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.nationality,
    required this.idType,
    required this.nic,
    required this.licenseNo,
    this.profilePic,
    this.role = 'renter',
    this.verificationStatus = 'pending',
    this.status = 'active',
    this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      nationality: json['nationality'] as String? ?? '',
      idType: json['idType'] as String? ?? 'NIC',
      nic: json['nic'] as String? ?? '',
      licenseNo: json['licenseNo'] as String? ?? '',
      profilePic: json['profilePic'] as String?,
      role: json['role'] as String? ?? 'renter',
      verificationStatus: json['verificationStatus'] as String? ?? 'pending',
      status: json['status'] as String? ?? 'active',
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'nationality': nationality,
      'idType': idType,
      'nic': nic,
      'licenseNo': licenseNo,
      'profilePic': profilePic,
      'role': role,
      'verificationStatus': verificationStatus,
      'status': status,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String source) =>
      UserModel.fromJson(jsonDecode(source) as Map<String, dynamic>);

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? profilePic,
    String? role,
    String? verificationStatus,
    String? status,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nationality: nationality,
      idType: idType,
      nic: nic,
      licenseNo: licenseNo,
      profilePic: profilePic ?? this.profilePic,
      role: role ?? this.role,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      status: status ?? this.status,
      reason: reason,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
