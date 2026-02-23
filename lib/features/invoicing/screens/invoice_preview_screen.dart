import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:tailorsync_v2/core/auth/models/app_user.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';
import 'package:tailorsync_v2/features/customers/models/customer.dart';
import 'package:tailorsync_v2/features/jobs/models/job_model.dart';
import 'package:tailorsync_v2/features/invoicing/services/invoice_service.dart';
import 'dart:typed_data';

class InvoicePreviewScreen extends ConsumerStatefulWidget {
  final JobModel job;
  final Customer customer;

  const InvoicePreviewScreen({
    super.key,
    required this.job,
    required this.customer,
  });

  @override
  ConsumerState<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends ConsumerState<InvoicePreviewScreen> {
  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileNotifierProvider).valueOrNull;

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareInvoice(profile),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printInvoice(profile),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format, profile),
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }

  Future<Uint8List> _generatePdf(dynamic format, AppUser profile) async {
    final invoiceService = ref.read(invoiceServiceProvider);
    return await invoiceService.generateInvoiceBytes(
      job: widget.job,
      customer: widget.customer,
      profile: profile,
    );
  }

  Future<void> _shareInvoice(AppUser profile) async {
    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final invoiceService = ref.read(invoiceServiceProvider);
      final bytes = await invoiceService.generateInvoiceBytes(
        job: widget.job,
        customer: widget.customer,
        profile: profile,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      await Printing.sharePdf(
        bytes: bytes, 
        filename: 'Invoice_${widget.job.title.replaceAll(" ", "_")}.pdf'
      );
    } catch (e) {
      if (!mounted) return;
      // Close loading if it's still open (simplistic check, in real app might track dialog state)
      Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
    }
  }

  Future<void> _printInvoice(AppUser profile) async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final invoiceService = ref.read(invoiceServiceProvider);
      final bytes = await invoiceService.generateInvoiceBytes(
        job: widget.job,
        customer: widget.customer,
        profile: profile,
      );

      if (!mounted) return;
      Navigator.pop(context);

      await Printing.layoutPdf(
        onLayout: (format) => bytes,
        name: 'Invoice_${widget.job.title}',
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error printing: $e')));
    }
  }
}
