class RegistrationRequest {
  final String email;
  final String password;
  final String socialId;
  final String phoneNumber;
  final String role;
  final String firstName;
  final String lastName;
  final String healthCardNo;
  final String tenantId;

  RegistrationRequest({
    required this.email,
    required this.password,
    required this.socialId,
    required this.phoneNumber,
    this.role = 'PATIENT',
    required this.firstName,
    required this.lastName,
    required this.healthCardNo,
    required this.tenantId,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'socialId': socialId,
      'phoneNumber': phoneNumber,
      'role': role,
      'firstName': firstName,
      'lastName': lastName,
      'healthCardNo': healthCardNo,
      'tenantId': tenantId,
    };
  }
}
