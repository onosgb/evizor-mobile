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
  final String? profilePhotoUrl;

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
    this.profilePhotoUrl,
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
      dob: json['dob'] != null
          ? DateTime.tryParse(json['dob'].toString())
          : null,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
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
      'profilePhotoUrl': profilePhotoUrl,
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
    String? profilePhotoUrl,
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
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }

  /// Check if full profile data is available
  bool get hasFullProfile => dob != null || gender != null || address != null;
}
