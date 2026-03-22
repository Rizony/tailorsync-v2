import 'package:hive_ce/hive.dart';
import 'package:tailorsync_v2/features/customers/models/customer.dart';
import 'package:tailorsync_v2/features/orders/models/order_model.dart';
import 'package:tailorsync_v2/core/sync/models/sync_action.dart';

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 0;

  @override
  Customer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Customer(
      id: fields[0] as String?,
      fullName: fields[1] as String,
      phoneNumber: fields[2] as String?,
      email: fields[3] as String?,
      photoUrl: fields[4] as String?,
      measurements: (fields[5] as Map?)?.cast<String, dynamic>() ?? {},
      createdAt: fields[6] as DateTime?,
      userId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.photoUrl)
      ..writeByte(5)
      ..write(obj.measurements)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.userId);
  }
}

class OrderItemAdapter extends TypeAdapter<OrderItem> {
  @override
  final int typeId = 1;

  @override
  OrderItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderItem(
      name: fields[0] as String,
      quantity: fields[1] as int,
      price: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, OrderItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.price);
  }
}

class PaymentAdapter extends TypeAdapter<Payment> {
  @override
  final int typeId = 2;

  @override
  Payment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Payment(
      amount: fields[0] as double,
      date: fields[1] as DateTime,
      note: fields[2] as String?,
      paymentMethod: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Payment obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.paymentMethod);
  }
}

class OrderModelAdapter extends TypeAdapter<OrderModel> {
  @override
  final int typeId = 3;

  @override
  OrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      customerId: fields[2] as String,
      title: fields[3] as String,
      price: fields[4] as double,
      balanceDue: fields[5] as double,
      dueDate: fields[6] as DateTime,
      status: fields[7] as String,
      images: (fields[8] as List?)?.cast<String>() ?? [],
      items: (fields[9] as List?)?.cast<OrderItem>() ?? [],
      payments: (fields[10] as List?)?.cast<Payment>() ?? [],
      fabricStatus: fields[11] as String,
      fabricSource: fields[12] as String?,
      notes: fields[13] as String?,
      createdAt: fields[14] as DateTime,
      assignedTo: fields[15] as String?,
      isOutsourced: fields[16] as bool,
      customerName: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.customerId)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.balanceDue)
      ..writeByte(6)
      ..write(obj.dueDate)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.images)
      ..writeByte(9)
      ..write(obj.items)
      ..writeByte(10)
      ..write(obj.payments)
      ..writeByte(11)
      ..write(obj.fabricStatus)
      ..writeByte(12)
      ..write(obj.fabricSource)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.assignedTo)
      ..writeByte(16)
      ..write(obj.isOutsourced)
      ..writeByte(17)
      ..write(obj.customerName);
  }
}

class SyncActionAdapter extends TypeAdapter<SyncAction> {
  @override
  final int typeId = 4;

  @override
  SyncAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncAction(
      id: fields[0] as String,
      actionType: fields[1] as String,
      endpoint: fields[2] as String,
      payload: (fields[3] as Map?)?.cast<String, dynamic>() ?? {},
      createdAt: fields[4] as DateTime,
      retryCount: fields[5] as int,
      error: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncAction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.actionType)
      ..writeByte(2)
      ..write(obj.endpoint)
      ..writeByte(3)
      ..write(obj.payload)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.retryCount)
      ..writeByte(6)
      ..write(obj.error);
  }
}
