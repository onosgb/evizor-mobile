import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/consultation_service.dart';
import '../models/create_appointment_request_model.dart';

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
  final List<SymptomSeverity>? draftSymptoms;
  final String? draftDescription;
  final String? draftDuration;
  final String? draftWeight;
  final String? draftHeight;
  final List<String>? draftUploadedFiles;

  AppointmentState({
    this.isLoading = false,
    this.appointment,
    this.error,
    this.draftSymptoms,
    this.draftDescription,
    this.draftDuration,
    this.draftWeight,
    this.draftHeight,
    this.draftUploadedFiles,
  });

  AppointmentState copyWith({
    bool? isLoading,
    Map<String, dynamic>? appointment,
    String? error,
    List<SymptomSeverity>? draftSymptoms,
    String? draftDescription,
    String? draftDuration,
    String? draftWeight,
    String? draftHeight,
    List<String>? draftUploadedFiles,
  }) {
    return AppointmentState(
      isLoading: isLoading ?? this.isLoading,
      appointment: appointment ?? this.appointment,
      error: error ?? this.error,
      draftSymptoms: draftSymptoms ?? this.draftSymptoms,
      draftDescription: draftDescription ?? this.draftDescription,
      draftDuration: draftDuration ?? this.draftDuration,
      draftWeight: draftWeight ?? this.draftWeight,
      draftHeight: draftHeight ?? this.draftHeight,
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
    required List<SymptomSeverity> symptoms,
    required String description,
    required String duration,
    String? weight,
    String? height,
  }) {
    state = state.copyWith(
      draftSymptoms: symptoms,
      draftDescription: description,
      draftDuration: duration,
      draftWeight: weight,
      draftHeight: height,
    );
  }

  /// Save uploaded files to draft state
  void saveUploadedFiles(List<String> files) {
    state = state.copyWith(draftUploadedFiles: files);
  }

  /// Submit the draft appointment to the database
  Future<void> submitAppointment() async {
    // Validate that draft data exists
    if (state.draftSymptoms == null ||
        state.draftDescription == null ||
        state.draftDuration == null) {
      state = state.copyWith(error: 'Please complete all required fields');
      throw Exception('Incomplete appointment data');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final appointmentData = CreateAppointmentRequest(
        symptoms: state.draftSymptoms!,
        description: state.draftDescription!,
        duration: state.draftDuration!,
        weight: state.draftWeight,
        height: state.draftHeight,
        attachments: state.draftUploadedFiles,
      );

      final appointment = await _consultationService.createAppointment(
        appointmentData,
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
    required List<SymptomSeverity> symptoms,
    required String description,
    required String duration,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final appointmentData = CreateAppointmentRequest(
        symptoms: symptoms,
        description: description,
        duration: duration,
      );

      final appointment = await _consultationService.createAppointment(
        appointmentData,
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
