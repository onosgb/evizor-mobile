/// Appointment model representing a scheduled or past appointment
enum AppointmentStatus {
  scheduled,
  cancelled,
  progress,
  completed,
  clinical,
  unknown,
}

/// Symptom item in an appointment (name + severity)
class AppointmentSymptom {
  final String name;
  final int severity;

  const AppointmentSymptom({required this.name, required this.severity});

  factory AppointmentSymptom.fromJson(Map<String, dynamic> json) {
    return AppointmentSymptom(
      name: json['name'] as String? ?? '',
      severity: json['severity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'severity': severity};
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
  final List<AppointmentSymptom> symptoms;
  final String? patientHeight;
  final String? patientWeight;
  final String? doctorSpecialty;
  final String? patientImageUrl;
  final String? doctorImageUrl;
  final String? patientRegisteredDate;
  final String? patientDob;
  final String? tenantId;
  final int? queuePosition;
  final String? doctorNotes;

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
    this.tenantId,
    this.queuePosition,
    this.doctorNotes,
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
      symptoms: _parseSymptoms(json['symptoms']),
      patientHeight: json['patientHeight']?.toString(),
      patientWeight: json['patientWeight']?.toString(),
      doctorSpecialty: json['doctorSpecialty']?.toString(),
      patientImageUrl: json['patientImageUrl']?.toString(),
      doctorImageUrl: json['doctorImageUrl']?.toString(),
      patientRegisteredDate: json['patientRegisteredDate']?.toString(),
      patientDob: json['patientDob']?.toString(),
      tenantId: json['tenantId']?.toString(),
      queuePosition: json['queuePosition'] is int
          ? json['queuePosition'] as int
          : (json['queuePosition'] is num
              ? (json['queuePosition'] as num).toInt()
              : null),
      doctorNotes: json['doctorNotes']?.toString(),
    );
  }

  static List<AppointmentSymptom> _parseSymptoms(dynamic value) {
    if (value is! List) return [];
    final list = <AppointmentSymptom>[];
    for (final e in value) {
      if (e is Map<String, dynamic>) {
        list.add(AppointmentSymptom.fromJson(e));
      }
    }
    return list;
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
      'symptoms': symptoms.map((s) => s.toJson()).toList(),
      'patientHeight': patientHeight,
      'patientWeight': patientWeight,
      'doctorSpecialty': doctorSpecialty,
      'patientImageUrl': patientImageUrl,
      'doctorImageUrl': doctorImageUrl,
      'patientRegisteredDate': patientRegisteredDate,
      'patientDob': patientDob,
      'tenantId': tenantId,
      'queuePosition': queuePosition,
      'doctorNotes': doctorNotes,
    };
  }
}
