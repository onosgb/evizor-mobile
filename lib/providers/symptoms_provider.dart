import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/consultation_service.dart';

/// Provider for ConsultationService instance
final consultationServiceProvider = Provider<ConsultationService>((ref) {
  return ConsultationService();
});

/// FutureProvider that fetches all symptoms from the API
/// Automatically caches the result and handles loading/error states
final symptomsProvider = FutureProvider<List<String>>((ref) async {
  final consultationService = ref.watch(consultationServiceProvider);
  return await consultationService.fetchSymptoms();
});
