import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tailorsync_v2/core/auth/models/app_user.dart';
import 'package:tailorsync_v2/features/customers/models/customer.dart';
import 'package:tailorsync_v2/features/jobs/models/job_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
// Removed unused dart:typed_data import

final invoiceServiceProvider = Provider((ref) => InvoiceService());

class InvoiceService {
  Future<void> generateInvoice({
    required JobModel job,
    required Customer customer,
    required AppUser profile,
  }) async {
    final pdf = pw.Document();
    
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    pw.MemoryImage? logoImage;
    if (profile.logoUrl != null && profile.logoUrl!.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(profile.logoUrl!));
        if (response.statusCode == 200) {
          logoImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        debugPrint('Error loading logo: $e'); // FIXED: Changed print to debugPrint
      }
    }
    
     pw.MemoryImage? signatureImage;
    if (profile.signatureUrl != null && profile.signatureUrl!.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(profile.signatureUrl!));
        if (response.statusCode == 200) {
          signatureImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
          debugPrint('Error loading signature: $e'); // FIXED: Changed print to debugPrint
      }
    }

    final accentColor = PdfColor.fromHex(profile.accentColor ?? '5D3FD3');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          height: 50,
                          width: 50,
                          child: pw.Image(logoImage),
                        ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        profile.brandName?.isNotEmpty == true ? profile.brandName! : (profile.shopName ?? 'Tailor Shop'),
                        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: accentColor),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text('#${job.id.substring(0, 8).toUpperCase()}'),
                      pw.Text('Date: ${DateFormat.yMMMd().format(DateTime.now())}'),
                      pw.Text('Due Date: ${DateFormat.yMMMd().format(job.dueDate)}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  children: [
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Billed To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
        
        // 1. fullName is required, so no null-check needed!
        pw.Text(customer.fullName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        
        // 2. phoneNumber is nullable, so we conditionally render the text row
        if (customer.phoneNumber != null && customer.phoneNumber!.isNotEmpty) 
          pw.Text(customer.phoneNumber!),
        
        // 3. email is also nullable, conditionally rendered
        if (customer.email != null && customer.email!.isNotEmpty) 
          pw.Text(customer.email!),
      ],
    ),
  ],
),
              pw.SizedBox(height: 40),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100), // FIXED: Added const
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                           crossAxisAlignment: pw.CrossAxisAlignment.start,
                           children: [
                             pw.Text('Tailoring Service: ${job.title}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                             if (job.notes != null) pw.Text(job.notes!, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                           ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8), 
                        child: pw.Text(_formatCurrency(job.price), textAlign: pw.TextAlign.right)
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 20),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      children: [
                        _buildTotalRow('Subtotal', job.price),
                        if (profile.defaultTaxRate > 0)
                          _buildTotalRow('Tax (${profile.defaultTaxRate}%)', job.price * (profile.defaultTaxRate / 100)),
                         
                        pw.Divider(), 
                        _buildTotalRow(
                          'Total', 
                          job.price * (1 + (profile.defaultTaxRate / 100)),
                          isBold: true,
                          color: accentColor,
                        ),
                        pw.SizedBox(height: 4),
                        
                        // FIXED: Removed the duplicate job.balanceDue parameter
                        _buildTotalRow(
                          'Balance Due', 
                          job.balanceDue, 
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              pw.Spacer(),

              if (profile.invoiceNotes != null) ...[
                pw.Text('Notes:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(profile.invoiceNotes!),
                pw.SizedBox(height: 10),
              ],
              
              if (profile.termsAndConditions != null) ...[
                pw.Text('Terms & Conditions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(profile.termsAndConditions!, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 20),
              ],
              
              if (signatureImage != null)
                pw.Container(
                  height: 40,
                  alignment: pw.Alignment.centerRight,
                  child: pw.Image(signatureImage),
                ),
                
              pw.Divider(color: accentColor),
              pw.Center(child: pw.Text('Thank you for your business!', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: accentColor))),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice-${job.id.substring(0, 8)}',
    );
  }

  pw.Widget _buildTotalRow(String label, double value, {bool isBold = false, PdfColor? color}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : null, color: color)),
        pw.Text(_formatCurrency(value), style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : null, color: color)),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return '₦${amount.toStringAsFixed(2)}'; 
  }
}