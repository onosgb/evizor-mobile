import 'user_model.dart';

/// Login response data model
///
/// Contains authentication tokens and user information returned from login
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  final bool profileCompleted;
  final bool profileVerified;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.profileCompleted,
    required this.profileVerified,
  });

  /// Create LoginResponse from JSON
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      profileCompleted: json['profileCompleted'] as bool? ?? false,
      profileVerified: json['profileVerified'] as bool? ?? false,
    );
  }

  /// Convert LoginResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'profileCompleted': profileCompleted,
      'profileVerified': profileVerified,
    };
  }
}
