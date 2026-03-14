class Medication {
  final String drug;
  final String frequency;
  final String dosage;
  final String instructions;

  Medication({
    required this.drug,
    required this.frequency,
    required this.dosage,
    required this.instructions,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      drug: json['drug'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drug': drug,
      'frequency': frequency,
      'dosage': dosage,
      'instructions': instructions,
    };
  }
}

class Prescription {
  final String phamacy;
  final String phamacyAddress;
  final String phamacyPhone;
  final String appointmentId;
  final String prescriptionId;
  final String doctor;
  final String status;
  final String? doctorNotes;
  final List<Medication> medications;

  Prescription({
    required this.phamacy,
    required this.phamacyAddress,
    required this.phamacyPhone,
    required this.appointmentId,
    required this.prescriptionId,
    required this.doctor,
    required this.status,
    this.doctorNotes,
    required this.medications,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      phamacy: json['phamacy'] as String? ?? '',
      phamacyAddress: json['phamacyAddress'] as String? ?? '',
      phamacyPhone: json['phamacyPhone'] as String? ?? '',
      appointmentId: json['appointmentId'] as String? ?? '',
      prescriptionId: json['prescriptionId'] as String? ?? '',
      doctor: json['doctor'] as String? ?? '',
      status: json['status'] as String? ?? '',
      doctorNotes: json['doctorNotes'] as String?,
      medications: (json['medications'] as List? ?? [])
          .map((m) => Medication.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phamacy': phamacy,
      'phamacyAddress': phamacyAddress,
      'phamacyPhone': phamacyPhone,
      'appointmentId': appointmentId,
      'prescriptionId': prescriptionId,
      'doctor': doctor,
      'status': status,
      'doctorNotes': doctorNotes,
      'medications': medications.map((m) => m.toJson()).toList(),
    };
  }
}
