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

  AppointmentState({this.isLoading = false, this.appointment, this.error});

  AppointmentState copyWith({
    bool? isLoading,
    Map<String, dynamic>? appointment,
    String? error,
  }) {
    return AppointmentState(
      isLoading: isLoading ?? this.isLoading,
      appointment: appointment ?? this.appointment,
      error: error ?? this.error,
    );
  }
}

/// StateNotifier for managing appointment creation
class AppointmentNotifier extends StateNotifier<AppointmentState> {
  final ConsultationService _consultationService;

  AppointmentNotifier(this._consultationService) : super(AppointmentState());

  /// Create a new appointment with symptoms
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
