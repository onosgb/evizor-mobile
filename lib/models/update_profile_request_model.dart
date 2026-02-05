class UpdateProfileRequest {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String healthCardNo;
  final DateTime? dob;
  final String? gender;
  final String? address;
  final String? bloodGroup;

  UpdateProfileRequest({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.healthCardNo,
    this.dob,
    this.gender,
    this.address,
    this.bloodGroup,
  });

  /// Create UpdateProfileRequest from User model
  factory UpdateProfileRequest.fromUser(dynamic user) {
    return UpdateProfileRequest(
      phoneNumber: user.phoneNumber,
      firstName: user.firstName,
      lastName: user.lastName,
      healthCardNo: user.healthCardNo,
      dob: user.dob,
      gender: user.gender,
      address: user.address,
      bloodGroup: user.bloodGroup,
    );
  }

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'healthCardNo': healthCardNo,
      'dob': dob?.toIso8601String(),
      'gender': gender,
      'address': address,
      'bloodGroup': bloodGroup,
    };
  }

  /// Create a copy with updated fields
  UpdateProfileRequest copyWith({
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? healthCardNo,
    DateTime? dob,
    String? gender,
    String? address,
    String? bloodGroup,
  }) {
    return UpdateProfileRequest(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      healthCardNo: healthCardNo ?? this.healthCardNo,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      bloodGroup: bloodGroup ?? this.bloodGroup,
    );
  }
}
