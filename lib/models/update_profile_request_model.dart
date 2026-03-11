class UpdateProfileRequest {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String healthCardNo;
  final DateTime? dob;
  final String? gender;
  final String? address;
  final String? bloodGroup;
  final double? weight;
  final double? height;

  UpdateProfileRequest({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.healthCardNo,
    this.dob,
    this.gender,
    this.address,
    this.bloodGroup,
    this.weight,
    this.height,
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
      weight: user.weight,
      height: user.height,
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
      'weight': weight,
      'height': height,
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
    double? weight,
    double? height,
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
      weight: weight ?? this.weight,
      height: height ?? this.height,
    );
  }
}
