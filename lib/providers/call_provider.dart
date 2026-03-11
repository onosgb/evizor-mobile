import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/appointment_service.dart';

enum CallStatus { idle, calling, incoming, active }

class CallState {
  final Map<String, dynamic>? payload;
  final CallStatus status;
  final String? dyteToken;

  CallState({this.payload, this.status = CallStatus.idle, this.dyteToken});

  CallState copyWith({
    Map<String, dynamic>? payload,
    CallStatus? status,
    String? dyteToken,
  }) {
    return CallState(
      payload: payload ?? this.payload,
      status: status ?? this.status,
      dyteToken: dyteToken ?? this.dyteToken,
    );
  }
}

class CallNotifier extends StateNotifier<CallState> {
  CallNotifier() : super(CallState());

  void handleProgress(Map<String, dynamic> data) {
    state = state.copyWith(payload: data, status: CallStatus.calling);
  }

  void handleIncoming(Map<String, dynamic> data) {
    print("Incoming call: $data");
    state = state.copyWith(payload: data, status: CallStatus.incoming);
  }

  Future<String?> acceptCall(String appointmentId) async {
    try {
      final service = AppointmentService();
      final token = await service.acceptAppointment(appointmentId);
      print("Accepted call: $token");
      state = state.copyWith(dyteToken: token, status: CallStatus.active);
      return token;
    } catch (e) {
      print("Error accepting call: $e");
      state = state.copyWith(status: CallStatus.idle);
      rethrow;
    }
  }

  Future<void> rejectCall(String appointmentId) async {
    try {
      final service = AppointmentService();
      await service.rejectAppointment(appointmentId);
      state = CallState(); // Reset state on rejection
    } catch (e) {
      print("Error rejecting call: $e");
      state = state.copyWith(status: CallStatus.idle);
      rethrow;
    }
  }

  void clear() {
    state = CallState();
  }
}

final callProvider = StateNotifierProvider<CallNotifier, CallState>((ref) {
  return CallNotifier();
});
