import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/marketplace_request.dart';

part 'marketplace_repository.g.dart';

class MarketplaceRepository {
  final SupabaseClient _client;

  MarketplaceRepository(this._client);

  Future<List<MarketplaceRequest>> getRequests() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('marketplace_requests')
        .select()
        .eq('tailor_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => MarketplaceRequest.fromJson(e)).toList();
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _client
        .from('marketplace_requests')
        .update({'status': status})
        .eq('id', requestId);
  }
}

@riverpod
MarketplaceRepository marketplaceRepository(MarketplaceRepositoryRef ref) {
  return MarketplaceRepository(Supabase.instance.client);
}

@riverpod
Future<List<MarketplaceRequest>> marketplaceRequests(MarketplaceRequestsRef ref) {
  return ref.watch(marketplaceRepositoryProvider).getRequests();
}
