import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/consultation_service.dart';

/// Provider for ConsultationService instance
final consultationServiceForAppointmentProvider = Provider<ConsultationService>(
  (ref) {
    return ConsultationService();
  },
);

/// State class for appointment creation
class AppointmentState {
  final bool isLoading;
  final Map<String, dynamic>? appointment;
  final String? error;

  // Draft appointment data (before submission)
  final List<String>? draftSymptomIds;
  final String? draftDescription;
  final String? draftDuration;
  final int? draftSeverity;
  final List<String>? draftUploadedFiles;

  AppointmentState({
    this.isLoading = false,
    this.appointment,
    this.error,
    this.draftSymptomIds,
    this.draftDescription,
    this.draftDuration,
    this.draftSeverity,
    this.draftUploadedFiles,
  });

  AppointmentState copyWith({
    bool? isLoading,
    Map<String, dynamic>? appointment,
    String? error,
    List<String>? draftSymptomIds,
    String? draftDescription,
    String? draftDuration,
    int? draftSeverity,
    List<String>? draftUploadedFiles,
  }) {
    return AppointmentState(
      isLoading: isLoading ?? this.isLoading,
      appointment: appointment ?? this.appointment,
      error: error ?? this.error,
      draftSymptomIds: draftSymptomIds ?? this.draftSymptomIds,
      draftDescription: draftDescription ?? this.draftDescription,
      draftDuration: draftDuration ?? this.draftDuration,
      draftSeverity: draftSeverity ?? this.draftSeverity,
      draftUploadedFiles: draftUploadedFiles ?? this.draftUploadedFiles,
    );
  }
}

/// StateNotifier for managing appointment creation
class AppointmentNotifier extends StateNotifier<AppointmentState> {
  final ConsultationService _consultationService;

  AppointmentNotifier(this._consultationService) : super(AppointmentState());

  /// Save draft appointment data without submitting to database
  void saveDraftAppointment({
    required List<String> symptomIds,
    required String description,
    required String duration,
    required int severity,
  }) {
    state = state.copyWith(
      draftSymptomIds: symptomIds,
      draftDescription: description,
      draftDuration: duration,
      draftSeverity: severity,
    );
  }

  /// Save uploaded files to draft state
  void saveUploadedFiles(List<String> files) {
    state = state.copyWith(draftUploadedFiles: files);
  }

  /// Submit the draft appointment to the database
  Future<void> submitAppointment() async {
    // Validate that draft data exists
    if (state.draftSymptomIds == null ||
        state.draftDescription == null ||
        state.draftDuration == null ||
        state.draftSeverity == null) {
      state = state.copyWith(error: 'Please complete all required fields');
      throw Exception('Incomplete appointment data');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final appointment = await _consultationService.createAppointment(
        symptomIds: state.draftSymptomIds!,
        description: state.draftDescription!,
        duration: state.draftDuration!,
        severity: state.draftSeverity!,
        attachments: state.draftUploadedFiles,
      );

      state = state.copyWith(
        isLoading: false,
        appointment: appointment,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Create a new appointment with symptoms (legacy method for backward compatibility)
  Future<void> createAppointment({
    required List<String> symptomIds,
    required String description,
    required String duration,
    required int severity,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final appointment = await _consultationService.createAppointment(
        symptomIds: symptomIds,
        description: description,
        duration: duration,
        severity: severity,
      );

      state = state.copyWith(
        isLoading: false,
        appointment: appointment,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Reset appointment state
  void reset() {
    state = AppointmentState();
  }
}

/// Provider for AppointmentNotifier
final appointmentNotifierProvider =
    StateNotifierProvider<AppointmentNotifier, AppointmentState>((ref) {
      final consultationService = ref.watch(
        consultationServiceForAppointmentProvider,
      );
      return AppointmentNotifier(consultationService);
    });
