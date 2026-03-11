/// Appointment model representing a scheduled or past appointment
enum AppointmentStatus {
  scheduled,
  cancelled,
  progress,
  completed,
  clinical,
  unknown,
}

class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final AppointmentStatus status;
  final String description;
  final String duration;
  final int severity;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final List<String> attachments;
  final List<String> symptoms;
  final String? patientHeight;
  final String? patientWeight;
  final String? doctorSpecialty;
  final String? patientImageUrl;
  final String? doctorImageUrl;
  final String? patientRegisteredDate;
  final String? patientDob;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.status,
    required this.description,
    required this.duration,
    required this.severity,
    required this.scheduledAt,
    required this.createdAt,
    required this.attachments,
    required this.symptoms,
    this.patientHeight,
    this.patientWeight,
    this.doctorSpecialty,
    this.patientImageUrl,
    this.doctorImageUrl,
    this.patientRegisteredDate,
    this.patientDob,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? 'Unknown Patient',
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? 'Pending Assignment',
      status: _parseStatus(json['status'] as String?),
      description: json['description'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      severity: json['severity'] as int? ?? 0,
      scheduledAt:
          DateTime.tryParse(json['scheduledAt'] as String? ?? '') ??
          DateTime.now(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      attachments: json['attachments'] is List
          ? (json['attachments'] as List).map((e) => e.toString()).toList()
          : [],
      symptoms: json['symptoms'] is List
          ? (json['symptoms'] as List).map((e) => e.toString()).toList()
          : [],
      patientHeight: json['patientHeight']?.toString(),
      patientWeight: json['patientWeight']?.toString(),
      doctorSpecialty: json['doctorSpecialty']?.toString(),
      patientImageUrl: json['patientImageUrl']?.toString(),
      doctorImageUrl: json['doctorImageUrl']?.toString(),
      patientRegisteredDate: json['patientRegisteredDate']?.toString(),
      patientDob: json['patientDob']?.toString(),
    );
  }

  static AppointmentStatus _parseStatus(String? status) {
    if (status == null) return AppointmentStatus.unknown;
    switch (status.toLowerCase()) {
      case 'clinical':
        return AppointmentStatus.clinical;
      case 'scheduled':
        return AppointmentStatus.scheduled;
      case 'cancelled':
      case 'canceled':
        return AppointmentStatus.cancelled;
      case 'progress':
      case 'in_progress':
      case 'inprogress':
        return AppointmentStatus.progress;
      case 'completed':
        return AppointmentStatus.completed;
      default:
        return AppointmentStatus.unknown;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'status': status.toString().split('.').last,
      'description': description,
      'duration': duration,
      'severity': severity,
      'scheduledAt': scheduledAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'attachments': attachments,
      'symptoms': symptoms,
      'patientHeight': patientHeight,
      'patientWeight': patientWeight,
      'doctorSpecialty': doctorSpecialty,
      'patientImageUrl': patientImageUrl,
      'doctorImageUrl': doctorImageUrl,
      'patientRegisteredDate': patientRegisteredDate,
      'patientDob': patientDob,
    };
  }
}
