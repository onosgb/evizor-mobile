import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tenant_model.dart';
import '../services/tenant_service.dart';

/// Provider for TenantService instance
final tenantServiceProvider = Provider<TenantService>((ref) {
  return TenantService();
});

/// StateNotifier for managing tenants with caching and background refresh
class TenantsNotifier extends StateNotifier<AsyncValue<List<Tenant>>> {
  final TenantService _service;

  TenantsNotifier(this._service) : super(const AsyncValue.loading()) {
    init();
  }

  Future<void> init() async {
    // 1. Try to load from cache first
    final cached = await _service.getCachedTenants();
    if (cached != null && cached.isNotEmpty) {
      state = AsyncValue.data(cached);
    }

    // 2. Trigger background refresh
    await refresh();
  }

  Future<void> refresh() async {
    try {
      final tenants = await _service.fetchAllTenants();
      state = AsyncValue.data(tenants);
    } catch (e, st) {
      // If we already have cached data, don't overwrite with error unless it's a completely empty state
      if (!state.hasValue) {
        state = AsyncValue.error(e, st);
      }
    }
  }
}

/// Provider that manages the list of tenants/provinces
final tenantsProvider =
    StateNotifierProvider<TenantsNotifier, AsyncValue<List<Tenant>>>((ref) {
      final service = ref.watch(tenantServiceProvider);
      return TenantsNotifier(service);
    });

/// StateProvider for the currently selected tenant
/// Used to track which tenant/location the user has selected during signup
final selectedTenantProvider = StateProvider<Tenant?>((ref) => null);
