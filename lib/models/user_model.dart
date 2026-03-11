import 'package:intl/intl.dart';

DateTime? _parseDob(dynamic value) {
  if (value == null) return null;
  final raw = value.toString();
  // Try ISO 8601 first (e.g. "2008-02-04T00:00:00.000Z")
  final iso = DateTime.tryParse(raw);
  if (iso != null) return iso;
  // Fall back to JS Date.toString() format (e.g. "Mon Feb 04 2008")
  try {
    return DateFormat('EEE MMM dd yyyy').parse(raw);
  } catch (_) {}
  // Try without leading zero (e.g. "Mon Feb 4 2008")
  try {
    return DateFormat('EEE MMM d yyyy').parse(raw);
  } catch (_) {}
  return null;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }
  return null;
}

class User {
  // Basic info (from login)
  final String id;
  final String email;
  final String phoneNumber;
  final String role;
  final String firstName;
  final String lastName;
  final String socialId;
  final String healthCardNo;
  final String tenantId; // Province/location
  final bool isTwoFAEnabled;

  // Full profile info (fetched when needed)
  final DateTime? dob;
  final String? gender;
  final String? address;
  final String? bloodGroup;
  final String? profilePictureUrl;
  final double? weight;
  final double? height;

  User({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.socialId,
    required this.healthCardNo,
    required this.tenantId,
    this.isTwoFAEnabled = false,
    this.dob,
    this.gender,
    this.address,
    this.bloodGroup,
    this.profilePictureUrl,
    this.weight,
    this.height,
  });

  /// Get full name from firstName and lastName
  String get fullName => '$firstName $lastName'.trim();

  /// Create User from JSON map (handles both basic and full profile)
  /// Database always returns camelCase format
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role: json['role'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      socialId: json['socialId'] as String? ?? '',
      healthCardNo: json['healthCardNo'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      isTwoFAEnabled: json['isTwoFAEnabled'] as bool? ?? false,
      dob: _parseDob(json['dob']),
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      weight: _parseDouble(json['weight']),
      height: _parseDouble(json['height']),
    );
  }

  /// Create User from basic login info only
  /// Database always returns camelCase format
  factory User.fromBasicInfo(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role: json['role'] as String? ?? 'PATIENT',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      socialId: json['socialId'] as String? ?? '',
      healthCardNo: json['healthCardNo'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      isTwoFAEnabled: json['isTwoFAEnabled'] as bool? ?? false,
    );
  }

  /// Convert User to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'firstName': firstName,
      'lastName': lastName,
      'socialId': socialId,
      'healthCardNo': healthCardNo,
      'tenantId': tenantId,
      'isTwoFAEnabled': isTwoFAEnabled,
      'dob': dob?.toIso8601String(),
      'gender': gender,
      'address': address,
      'bloodGroup': bloodGroup,
      'profilePictureUrl': profilePictureUrl,
      'weight': weight,
      'height': height,
    };
  }

  /// Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? role,
    String? firstName,
    String? lastName,
    String? socialId,
    String? healthCardNo,
    String? tenantId,
    bool? isTwoFAEnabled,
    DateTime? dob,
    String? gender,
    String? address,
    String? bloodGroup,
    String? profilePictureUrl,
    double? weight,
    double? height,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      socialId: socialId ?? this.socialId,
      healthCardNo: healthCardNo ?? this.healthCardNo,
      tenantId: tenantId ?? this.tenantId,
      isTwoFAEnabled: isTwoFAEnabled ?? this.isTwoFAEnabled,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      weight: weight ?? this.weight,
      height: height ?? this.height,
    );
  }

  /// Check if full profile data is available
  bool get hasFullProfile => dob != null || gender != null || address != null;
}
