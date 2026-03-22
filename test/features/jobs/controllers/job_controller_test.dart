
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/features/orders/controllers/order_controller.dart';
import 'package:tailorsync_v2/features/orders/models/order_model.dart';
import 'package:tailorsync_v2/features/orders/repositories/order_repository.dart';

// Mock the repository class directly
class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late MockOrderRepository mockRepository;
  late ProviderContainer container;

  // Helpers
  final testOrder = OrderModel(
    id: '1',
    userId: 'user1',
    customerId: 'cust1',
    title: 'Test Suit',
    price: 10000,
    dueDate: DateTime.now(),
    status: OrderModel.statusQuote,
    items: [],
    images: [],
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockRepository = MockOrderRepository();
    container = ProviderContainer(
      overrides: [
        orderRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    
    // Register fallback values
    registerFallbackValue(testOrder);
  });

  tearDown(() {
    container.dispose();
  });

  test('OrderController.build fetches order from repository', () async {
    when(() => mockRepository.getOrder('1')).thenAnswer((_) async => Right(testOrder));

    // Read the controller (this triggers build)
    final order = await container.read(orderControllerProvider('1').future);

    expect(order, testOrder);
    verify(() => mockRepository.getOrder('1')).called(1);
  });

  test('updateStatus calls repository and updates state', () async {
    when(() => mockRepository.getOrder('1')).thenAnswer((_) async => Right(testOrder));
    when(() => mockRepository.updateOrder(any())).thenAnswer((_) async => const Right(unit));

    // initialize
    await container.read(orderControllerProvider('1').future);
    
    // Act
    await container.read(orderControllerProvider('1').notifier).updateStatus(OrderModel.statusInProgress);

    // Assert
    verify(() => mockRepository.updateOrder(any(that: isA<OrderModel>()
      .having((o) => o.status, 'status', OrderModel.statusInProgress)
    ))).called(1);

    // State should be updated
    final newState = container.read(orderControllerProvider('1'));
    expect(newState.value?.status, OrderModel.statusInProgress);
  });

  test('convertQuoteToOrder updates status and balance', () async {
    when(() => mockRepository.getOrder('1')).thenAnswer((_) async => Right(testOrder));
    when(() => mockRepository.updateOrder(any())).thenAnswer((_) async => const Right(unit));

    // initialize
    await container.read(orderControllerProvider('1').future);
    
    // Act: Deposit 2000, Total 10000 -> Balance 8000
    await container.read(orderControllerProvider('1').notifier).convertQuoteToOrder(2000, 10000);

    // Assert
    verify(() => mockRepository.updateOrder(any(that: isA<OrderModel>()
      .having((o) => o.status, 'status', OrderModel.statusPending)
      .having((o) => o.balanceDue, 'balanceDue', 8000)
    ))).called(1);
  });
}
