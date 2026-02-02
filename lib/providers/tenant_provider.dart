import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tenant_model.dart';
import '../services/tenant_service.dart';

/// Provider for TenantService instance
final tenantServiceProvider = Provider<TenantService>((ref) {
  return TenantService();
});

/// FutureProvider that fetches all tenants from the API
/// Automatically caches the result and handles loading/error states
final tenantsProvider = FutureProvider<List<Tenant>>((ref) async {
  final tenantService = ref.watch(tenantServiceProvider);
  return await tenantService.fetchAllTenants();
});

/// StateProvider for the currently selected tenant
/// Used to track which tenant/location the user has selected during signup
final selectedTenantProvider = StateProvider<Tenant?>((ref) => null);
