class Consultation {
  final String id;
  final String appointmentId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime consultationDate;
  final String diagnosis;
  final String? doctorNotes;
  final TreatmentPlan? treatmentPlan;
  final Prescription? prescription;
  final List<String> attachments;

  Consultation({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.consultationDate,
    required this.diagnosis,
    this.doctorNotes,
    this.treatmentPlan,
    this.prescription,
    this.attachments = const [],
  });
}

class TreatmentPlan {
  final String instructions;
  final List<String> recommendations;
  final DateTime? followUpDate;

  TreatmentPlan({
    required this.instructions,
    this.recommendations = const [],
    this.followUpDate,
  });
}

class Prescription {
  final String id;
  final List<Medication> medications;
  final DateTime issueDate;
  final DateTime? expiryDate;

  Prescription({
    required this.id,
    required this.medications,
    required this.issueDate,
    this.expiryDate,
  });
}

class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final int durationDays;
  final String? instructions;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.durationDays,
    this.instructions,
  });
}
