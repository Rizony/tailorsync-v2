import '../persistence/session_storage.dart';
import 'invoice.dart';
import 'invoice_dto.dart';

class InvoiceRepository {
  Future<List<Invoice>> loadAll() async {
    final raw = await SessionStorage.loadInvoices();

    return raw
        .map((e) => InvoiceDto.fromJson(e))
        .toList();
  }

  Future<void> saveAll(List<Invoice> invoices) async {
    await SessionStorage.saveInvoices(
      invoices.map(InvoiceDto.toJson).toList(),
    );
  }
}
