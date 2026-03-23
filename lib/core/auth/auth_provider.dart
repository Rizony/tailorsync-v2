import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_ce/hive.dart';
import 'package:needlix/features/customers/models/customer.dart';
import 'package:needlix/features/orders/models/order_model.dart';
import 'package:needlix/core/sync/models/sync_action.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  Stream<AuthState> build() {
    return Supabase.instance.client.auth.onAuthStateChange;
  }

  Future<void> signOut() async {
    try {
      if (Hive.isBoxOpen('customers')) await Hive.box<Customer>('customers').clear();
      if (Hive.isBoxOpen('orders')) await Hive.box<OrderModel>('orders').clear();
      if (Hive.isBoxOpen('sync_queue')) await Hive.box<SyncAction>('sync_queue').clear();
    } catch (_) {}
    await Supabase.instance.client.auth.signOut();
  }
}