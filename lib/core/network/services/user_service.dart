import 'package:dio/dio.dart';
import '../api_client.dart';

class UpdateUserRequest {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? city;
  final String? profileImageUrl;

  UpdateUserRequest({
    this.firstName,
    this.lastName,
    this.email,
    this.city,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (firstName != null) map['firstName'] = firstName;
    if (lastName != null) map['lastName'] = lastName;
    if (email != null) map['email'] = email;
    if (city != null) map['city'] = city;
    if (profileImageUrl != null) map['profileImageUrl'] = profileImageUrl;
    return map;
  }
}

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<Response> getProfile() async {
    return await _apiClient.get('/users/profile');
  }

  Future<Response> updateProfile(UpdateUserRequest request) async {
    return await _apiClient.put('/users/profile', data: request.toJson());
  }

  Future<Response> getWallet() async {
    return await _apiClient.get('/users/wallet');
  }
}
