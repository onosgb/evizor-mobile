import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prescription_model.dart';
import 'appointment_provider.dart';

final prescriptionProvider = FutureProvider.autoDispose.family<Prescription, String>((ref, appointmentId) async {
  final service = ref.watch(appointmentServiceProvider);
  return service.fetchPrescription(appointmentId);
});
