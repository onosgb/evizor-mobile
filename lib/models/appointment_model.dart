/// Appointment model for creating new appointments
class Appointment {
  final List<String> symtomps; // List of symptom IDs
  final String description; // Detailed symptom description
  final String duration; // How long symtomps have been present
  final int severity; // Severity level (1-10)
  final String? status;
  final List<String>? attachments; // Optional file attachments

  Appointment({
    required this.symtomps,
    required this.description,
    required this.duration,
    required this.severity,
    this.attachments,
    this.status,
  });

  /// Create Appointment from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      symtomps: json['symtomps'] is List
          ? (json['symtomps'] as List).map((e) => e.toString()).toList()
          : [],
      description: json['description'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      severity: json['severity'] as int? ?? 1,
      attachments: json['attachments'] is List
          ? (json['attachments'] as List).map((e) => e.toString()).toList()
          : null,
      status: json['status'] as String? ?? 'Pending',
    );
  }

  /// Convert Appointment to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'symtomps': symtomps,
      'description': description,
      'duration': duration,
      'severity': severity,
      if (attachments != null && attachments!.isNotEmpty)
        'attachments': attachments,
    };
  }
}
