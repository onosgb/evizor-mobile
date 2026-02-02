class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? nationalId;
  final String? address;
  final String? profilePhotoUrl;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.dateOfBirth,
    this.gender,
    this.nationalId,
    this.address,
    this.profilePhotoUrl,
  });
}
