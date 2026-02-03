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

  // Full profile info (fetched when needed)
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
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
    this.dateOfBirth,
    this.gender,
    this.address,
    this.profilePhotoUrl,
  });

  /// Get full name from firstName and lastName
  String get fullName => '$firstName $lastName'.trim();

  /// Create User from JSON map (handles both basic and full profile)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber:
          json['phoneNumber'] as String? ?? json['phone'] as String? ?? '',
      role: json['role'] as String? ?? '',
      firstName:
          json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastName:
          json['lastName'] as String? ?? json['last_name'] as String? ?? '',
      socialId:
          json['socialId'] as String? ?? json['social_id'] as String? ?? '',
      healthCardNo:
          json['healthCardNo'] as String? ??
          json['health_card_no'] as String? ??
          '',
      tenantId:
          json['tenantId'] as String? ?? json['tenant_id'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'].toString())
          : null,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      profilePhotoUrl:
          json['profilePhotoUrl'] as String? ??
          json['profile_photo_url'] as String?,
    );
  }

  /// Create User from basic login info only
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
      tenantId:
          json['tenantId'] as String? ?? json['tenant_id'] as String? ?? '',
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
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
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
    DateTime? dateOfBirth,
    String? gender,
    String? address,
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
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }

  /// Check if full profile data is available
  bool get hasFullProfile =>
      dateOfBirth != null || gender != null || address != null;
}
