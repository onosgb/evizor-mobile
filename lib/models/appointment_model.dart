class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String? doctorPhotoUrl;
  final DateTime scheduledTime;
  final String status; // 'upcoming', 'completed', 'cancelled', 'in-progress'
  final String consultationType; // 'general', 'specialist', 'follow-up'
  final String? symptoms;
  final List<String> attachments;
  final int? queuePosition;
  final int? estimatedWaitMinutes;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    this.doctorPhotoUrl,
    required this.scheduledTime,
    required this.status,
    required this.consultationType,
    this.symptoms,
    this.attachments = const [],
    this.queuePosition,
    this.estimatedWaitMinutes,
  });
}
