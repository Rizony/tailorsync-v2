import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'invoice.dart';
import 'invoice_dto.dart';

class InvoiceStorage {
  static const _keyInvoices = 'invoices';

  static Future<void> saveAll(List<Invoice> invoices) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = invoices
        .map((i) => jsonEncode(InvoiceDto.toJson(i)))
        .toList();

    await prefs.setStringList(_keyInvoices, encoded);
  }
static const _invoicesKey = 'invoices';

static Future<void> saveInvoices(
  List<Map<String, dynamic>> invoices,
) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(_invoicesKey, jsonEncode(invoices));
}

static Future<List<Map<String, dynamic>>> loadInvoices() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_invoicesKey);

  if (raw == null) return [];

  final decoded = jsonDecode(raw) as List;
  return decoded.cast<Map<String, dynamic>>();
}

  static Future<List<Invoice>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    final stored = prefs.getStringList(_keyInvoices);
    if (stored == null) return [];


    return stored
        .map((e) => InvoiceDto.fromJson(jsonDecode(e)))
        .toList();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyInvoices);
  }
}
