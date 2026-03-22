import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorsync_v2/core/auth/auth_provider.dart';
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

  Future<void> updateRequestQuote({
    required String requestId,
    required double quoteAmount,
    String quoteCurrency = 'NGN',
    String? quoteMessage,
  }) async {
    await _client.from('marketplace_requests').update({
      'quote_amount': quoteAmount,
      'quote_currency': quoteCurrency,
      'quote_message': quoteMessage,
      'quoted_at': DateTime.now().toIso8601String(),
      'quoted_by': _client.auth.currentUser?.id,
    }).eq('id', requestId);
  }

  Future<void> setQuoteStatus({
    required String requestId,
    required String quoteStatus,
  }) async {
    await _client
        .from('marketplace_requests')
        .update({'quote_status': quoteStatus})
        .eq('id', requestId);
  }

  Future<void> acceptCounterOffer({
    required MarketplaceRequest request,
  }) async {
    final counter = request.counterOfferAmount;
    if (counter == null || counter <= 0) return;
    await _client.from('marketplace_requests').update({
      'quote_amount': counter,
      'quote_status': 'accepted',
      'counter_offer_amount': null,
      'counter_offer_message': null,
      'counter_offered_at': null,
      'quoted_at': DateTime.now().toIso8601String(),
      'quoted_by': _client.auth.currentUser?.id,
    }).eq('id', request.id);
  }

  Stream<List<MarketplaceRequest>> watchRequests() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _client
        .from('marketplace_requests')
        .stream(primaryKey: ['id'])
        .eq('tailor_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => MarketplaceRequest.fromJson(e)).toList());
  }

  Future<void> acceptAndCreateOrder({
    required MarketplaceRequest request,
    required String orderId,
    required String customerId,
    required String title,
    required DateTime dueDate,
    required double price,
  }) async {
    // 1. Update the request status and link the created order
    await _client.from('marketplace_requests').update({
      'status': 'accepted',
      'order_id': orderId,
    }).eq('id', request.id);
  }
}

@riverpod
MarketplaceRepository marketplaceRepository(MarketplaceRepositoryRef ref) {
  // SECURITY: Watch AuthState so this provider recalculates on login/logout
  ref.watch(authControllerProvider);
  return MarketplaceRepository(Supabase.instance.client);
}

@riverpod
Stream<List<MarketplaceRequest>> marketplaceRequestsStream(MarketplaceRequestsStreamRef ref) {
  return ref.watch(marketplaceRepositoryProvider).watchRequests();
}

@riverpod
Future<List<MarketplaceRequest>> marketplaceRequests(MarketplaceRequestsRef ref) {
  return ref.watch(marketplaceRepositoryProvider).getRequests();
}

@riverpod
int pendingMarketplaceRequestsCount(PendingMarketplaceRequestsCountRef ref) {
  final requestsAsync = ref.watch(marketplaceRequestsStreamProvider);
  return requestsAsync.when(
    data: (requests) => requests.where((r) => r.status == 'pending').length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}
