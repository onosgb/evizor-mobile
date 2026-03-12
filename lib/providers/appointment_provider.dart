import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';

class PaginatedAppointmentsState {
  final List<Appointment> appointments;
  final int page;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  PaginatedAppointmentsState({
    this.appointments = const [],
    this.page = 1,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  PaginatedAppointmentsState copyWith({
    List<Appointment>? appointments,
    int? page,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return PaginatedAppointmentsState(
      appointments: appointments ?? this.appointments,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}

class AppointmentsNotifier
    extends StateNotifier<AsyncValue<PaginatedAppointmentsState>> {
  final AppointmentService _service;

  AppointmentsNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchInitial();
  }

  Future<void> fetchInitial() async {
    try {
      try {
        state = const AsyncValue.loading();
      } catch (_) {
        return; // Notifier already disposed
      }
      final appointments = await _service.fetchAppointments(page: 1, limit: 10);
      try {
        state = AsyncValue.data(
          PaginatedAppointmentsState(
            appointments: appointments,
            page: 1,
            hasMore: appointments.length >= 10,
          ),
        );
      } catch (_) {
        // Ignore if notifier was disposed during the async gap
      }
    } catch (e, st) {
      try {
        state = AsyncValue.error(e, st);
      } catch (_) {
        // Ignore if notifier was disposed (e.g. user navigated away)
      }
    }
  }

  Future<void> fetchMore() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.page + 1;
      final moreAppointments = await _service.fetchAppointments(
        page: nextPage,
        limit: 10,
      );

      state = AsyncValue.data(
        currentState.copyWith(
          appointments: [...currentState.appointments, ...moreAppointments],
          page: nextPage,
          isLoadingMore: false,
          hasMore: moreAppointments.length >= 10,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoadingMore: false, error: e.toString()),
      );
    }
  }

  void refresh() {
    fetchInitial();
  }
}

final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  return AppointmentService();
});

final appointmentsNotifierProvider =
    StateNotifierProvider.autoDispose<
      AppointmentsNotifier,
      AsyncValue<PaginatedAppointmentsState>
    >((ref) {
      final service = ref.watch(appointmentServiceProvider);
      return AppointmentsNotifier(service);
    });

class LatestAppointmentNotifier extends AutoDisposeAsyncNotifier<Appointment?> {
  @override
  Future<Appointment?> build() async {
    final service = ref.watch(appointmentServiceProvider);
    return service.fetchLatestAppointment();
  }

  /// Manually update the state (e.g. from a real-time signal)
  void updateState(Appointment? appointment) {
    state = AsyncValue.data(appointment);
  }

  /// Force a re-fetch
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(appointmentServiceProvider);
      return service.fetchLatestAppointment();
    });
  }
}

final latestAppointmentProvider =
    AsyncNotifierProvider.autoDispose<LatestAppointmentNotifier, Appointment?>(
      LatestAppointmentNotifier.new,
    );
