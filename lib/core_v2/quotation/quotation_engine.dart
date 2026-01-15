import 'package:uuid/uuid.dart';

import '../customers/customer_id.dart';
import '../measurements/garment_type.dart';
import 'fabric_cost.dart';
import 'garment_pricing.dart';
import 'quotation.dart';
import 'quotation_calculator.dart';
import 'quotation_line_item.dart';
import 'quotation_status.dart';

class QuotationEngine {
  static const _uuid = Uuid();

  /// Creates a new quotation in DRAFT state.
  static Quotation create({
    required CustomerId customerId,
    required GarmentType garment,
    FabricCost? fabric,
    double discount = 0,
    double extraCharges = 0,
  }) {
    final items = <QuotationLineItem>[];

    // Labor
    final labor = GarmentPricing.laborCost(garment);
    items.add(
      QuotationLineItem(
        label: 'Tailoring labor',
        amount: labor,
      ),
    );

    // Fabric
    if (fabric != null) {
      items.add(
        QuotationLineItem(
          label: '${fabric.fabricName} (${fabric.meters}m)',
          amount: fabric.total,
        ),
      );
    }

    // Extras
    if (extraCharges > 0) {
      items.add(
        QuotationLineItem(
          label: 'Extra charges',
          amount: extraCharges,
        ),
      );
    }

    final subtotal =
        QuotationCalculator.subtotal(items);

    final total = QuotationCalculator.applyDiscount(
      subtotal: subtotal,
      discount: discount,
    );

    return Quotation(
      id: _uuid.v4(),
      customerId: customerId,
      garment: garment,
      items: items,
      subtotal: subtotal,
      discount: discount,
      total: total,
      status: QuotationStatus.draft,
      createdAt: DateTime.now(),
    );
  }

  /// Finalizes a quotation.
  ///
  /// Once finalized:
  /// - Pricing is locked
  /// - Quotation can produce an Order
  static Quotation finalize(Quotation quotation) {
    if (quotation.status == QuotationStatus.finalized) {
      return quotation; // idempotent
    }

    if (quotation.status != QuotationStatus.draft) {
      throw StateError(
        'Only draft quotations can be finalized',
      );
    }

    return quotation.copyWith(
      status: QuotationStatus.finalized,
      finalizedAt: DateTime.now(),
    );
  }
}
