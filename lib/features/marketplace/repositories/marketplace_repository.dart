import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:needlix/core/auth/auth_provider.dart';
import 'package:needlix/core/sync/models/sync_action.dart';
import 'package:needlix/core/sync/sync_manager.dart';
import '../models/marketplace_request.dart';

part 'marketplace_repository.g.dart';


class MarketplaceRepository {
  final SupabaseClient _client;
  final Ref _ref;

  MarketplaceRepository(this._client, this._ref);

  Future<List<MarketplaceRequest>> getRequests() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('marketplace_requests')
        .select('*, profiles!tailor_id(full_name, rating), customer_profile:profiles!customer_id(customer_rating)')
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
      // Clear counter data so it doesn't leave "zombie" UI elements
      'counter_offer_amount': null,
      'counter_offer_message': null,
      'counter_offered_at': null,
    }).eq('id', requestId);
  }

  Future<void> declineCounterOffer({
    required MarketplaceRequest request,
  }) async {
    // Rejects the counter offer and returns to the initial 'quoted' status
    // The client will see their counter was rejected and they must accept the original quote
    await _client.from('marketplace_requests').update({
      'quote_status': 'pending',
      'counter_offer_amount': null,
      'counter_offer_message': null,
      'counter_offered_at': null,
    }).eq('id', request.id);
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
        .handleError((error) { print('Marketplace stream error ignored: $error'); })
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
    // We cannot update Supabase directly here because the newly created Order
    // is sitting in the local Hive sync_queue and hasn't reached Supabase yet.
    // If we update directly, Supabase throws a Foreign Key Violation on `order_id`.
    // Instead, we queue this update right behind the order in the sync queue!
    final syncBox = Hive.box<SyncAction>('sync_queue');
    
    final payload = {
      'id': request.id,
      'status': 'accepted',
      'order_id': orderId,
    };

    final action = SyncAction(
      id: const Uuid().v4(),
      actionType: SyncAction.actionUpdate,
      endpoint: 'marketplace_requests',
      payload: payload,
      createdAt: DateTime.now(),
    );
    
    await syncBox.add(action);

    // Trigger SyncManager to process the queue now that both actions are queued
    _ref.read(syncManagerProvider).processQueue();
  }

  Future<void> submitClientRating({
    required String requestId,
    required String tailorId,
    required String customerId,
    required int rating,
    String? review,
  }) async {
    await _client.from('marketplace_ratings').insert({
      'request_id': requestId,
      'tailor_id': tailorId,
      'customer_id': customerId,
      'rating': rating,
      'review': review,
      'rater_role': 'tailor',
    });
  }
}

@riverpod
MarketplaceRepository marketplaceRepository(MarketplaceRepositoryRef ref) {
  // SECURITY: Watch AuthState so this provider recalculates on login/logout
  ref.watch(authControllerProvider);
  return MarketplaceRepository(Supabase.instance.client, ref);
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
