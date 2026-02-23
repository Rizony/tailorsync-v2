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

final invoiceServiceProvider = Provider((ref) => InvoiceService());

class InvoiceService {
  Future<void> generateInvoice({
    required JobModel job,
    required Customer customer,
    required AppUser profile,
  }) async {
    final pdf = pw.Document();
    await _buildPdfContent(pdf, job, customer, profile);
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice-${job.id.substring(0, 8)}',
    );
  }

  Future<Uint8List> generateInvoiceBytes({
    required JobModel job,
    required Customer customer,
    required AppUser profile,
  }) async {
    final pdf = pw.Document();
    // ... duplicate logic for now, or refactor to internal _buildPdf method
    // For implementation speed and safety, let's extract the building logic
    await _buildPdfContent(pdf, job, customer, profile);
    return pdf.save();
  }

  Future<void> _buildPdfContent(pw.Document pdf, JobModel job, Customer customer, AppUser profile) async {
    // Load fonts with fallback
    pw.Font fontRegular;
    pw.Font fontBold;
    try {
      fontRegular = await PdfGoogleFonts.notoSansRegular();
      fontBold = await PdfGoogleFonts.notoSansBold();
    } catch (e) {
      debugPrint('Error loading fonts: $e');
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }

    // Safely parse accent color
    PdfColor accentColor;
    try {
      String cleanHex = (profile.accentColor ?? '5D3FD3')
          .replaceAll('#', '')
          .replaceAll('0x', '')
          .replaceAll('0X', '');
      if (cleanHex.length == 8) cleanHex = cleanHex.substring(2); 
      accentColor = PdfColor.fromHex(cleanHex);
    } catch (e) {
      debugPrint('Error parsing color: $e');
      accentColor = PdfColor.fromHex('5D3FD3');
    }

    // Load logo
    pw.MemoryImage? logoImage;
    if (profile.logoUrl != null && profile.logoUrl!.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(profile.logoUrl!));
        if (response.statusCode == 200) {
          logoImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        debugPrint('Error loading logo: $e');
      }
    }
    
    // Load signature
     pw.MemoryImage? signatureImage;
    if (profile.signatureUrl != null && profile.signatureUrl!.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(profile.signatureUrl!));
        if (response.statusCode == 200) {
          signatureImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
          debugPrint('Error loading signature: $e');
      }
    }

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
                      pw.SizedBox(height: 4),
                      if (profile.shopAddress != null) pw.Text(profile.shopAddress!, style: const pw.TextStyle(fontSize: 10)),
                      if (profile.phoneNumber != null) pw.Text(profile.phoneNumber!, style: const pw.TextStyle(fontSize: 10)),
                      if (profile.email != null) pw.Text(profile.email!, style: const pw.TextStyle(fontSize: 10)),
                      if (profile.website != null) pw.Text(profile.website!, style: const pw.TextStyle(fontSize: 10, color: PdfColors.blue)),
                      if (profile.socialMediaHandle != null) pw.Text(profile.socialMediaHandle!, style: const pw.TextStyle(fontSize: 10)),
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
                             if (job.items.isEmpty) ...[
                               pw.Text('Tailoring Service: ${job.title}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                             ] else ...[
                               for (var item in job.items)
                                 pw.Padding(
                                   padding: const pw.EdgeInsets.only(bottom: 4),
                                   child: pw.Row(
                                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                     children: [
                                       pw.Text('${item.quantity}x ${item.name}'),
                                     ]
                                   )
                                 ),
                             ],
                             if (job.notes != null) pw.Text(job.notes!, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                           ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8), 
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            if (job.items.isEmpty) ...[
                              pw.Text(_formatCurrency(job.price, profile.currencySymbol)),
                            ] else ...[
                              for (var item in job.items)
                                pw.Padding(
                                   padding: const pw.EdgeInsets.only(bottom: 4),
                                   child: pw.Text(_formatCurrency(item.price * item.quantity, profile.currencySymbol)),
                                ),
                            ],
                          ],
                        )
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
                        _buildTotalRow(
                          'Subtotal', 
                          job.price, 
                          profile.currencySymbol,
                        ),
                        pw.SizedBox(height: 4),
                        
                        if (job.balanceDue != job.price)
                          _buildTotalRow(
                            'Paid', 
                            job.price - job.balanceDue, 
                            profile.currencySymbol,
                            color: PdfColors.green,
                          ),
                        
                        if (profile.defaultTaxRate > 0)
                          _buildTotalRow(
                            'Tax (${profile.defaultTaxRate}%)', 
                            job.price * (profile.defaultTaxRate / 100), 
                            profile.currencySymbol,
                          ),
                          
                        pw.Divider(), 

                        _buildTotalRow(
                          'Total', 
                          job.price * (1 + (profile.defaultTaxRate / 100)),
                          profile.currencySymbol,
                          isBold: true,
                          color: accentColor,
                        ),
                        pw.SizedBox(height: 4),
                        
                        _buildTotalRow(
                          'Balance Due', 
                          job.balanceDue, 
                          profile.currencySymbol,
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
  }

  pw.Widget _buildTotalRow(String label, double value, String symbol, {bool isBold = false, PdfColor? color}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : null, color: color)),
        pw.Text(_formatCurrency(value, symbol), style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : null, color: color)),
      ],
    );
  }

  String _formatCurrency(double amount, String symbol) {
    return '$symbol${amount.toStringAsFixed(2)}'; 
  }
}