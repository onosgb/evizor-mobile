class SymptomSeverity {
  final String symptomId;
  final int severity;

  SymptomSeverity({required this.symptomId, required this.severity});

  factory SymptomSeverity.fromJson(Map<String, dynamic> json) {
    return SymptomSeverity(
      symptomId: json['symptomId'] as String? ?? '',
      severity: json['severity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {'symptomId': symptomId, 'severity': severity};
  }
}

/// Appointment request model for creating new appointments
class CreateAppointmentRequest {
  final List<SymptomSeverity> symptoms; // List of symptom severities
  final String description; // Detailed symptom description
  final String duration; // How long symptoms have been present
  final String? status;
  final String? weight;
  final String? height;
  final List<String>? attachments; // Optional file attachments

  CreateAppointmentRequest({
    required this.symptoms,
    required this.description,
    required this.duration,
    this.attachments,
    this.status,
    this.weight,
    this.height,
  });

  /// Create CreateAppointmentRequest from JSON
  factory CreateAppointmentRequest.fromJson(Map<String, dynamic> json) {
    return CreateAppointmentRequest(
      symptoms: json['symptoms'] is List
          ? (json['symptoms'] as List)
                .map((e) => SymptomSeverity.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      description: json['description'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      attachments: json['attachments'] is List
          ? (json['attachments'] as List).map((e) => e.toString()).toList()
          : null,
      status: json['status'] as String? ?? 'Pending',
      weight: json['weight'] as String? ?? '',
      height: json['height'] as String? ?? '',
    );
  }

  /// Convert CreateAppointmentRequest to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'symptoms': symptoms.map((e) => e.toJson()).toList(),
      'description': description,
      'duration': duration,
      if (attachments != null && attachments!.isNotEmpty)
        'attachments': attachments,
      'weight': weight,
      'height': height,
    };
  }
}
