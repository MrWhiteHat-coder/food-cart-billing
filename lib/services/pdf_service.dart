import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/bill.dart';
import '../models/cart_item.dart';
import '../utils/currency_formatter.dart';

class PdfService {
  static Future<String?> generateReceiptPdf(Bill bill, String shopName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: const pw.PageFormat(80 * 2.8346, double.infinity),
        margin: const pw.EdgeInsets.symmetric(horizontal: 4 * 2.8346),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(shopName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('Tax Invoice', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text('GSTIN: 27AABCT1332L1ZV', style: const pw.TextStyle(fontSize: 9)),
              pw.Divider(),
              pw.Text('Bill No: ${bill.id.substring(0, 8)}', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Date: ${_formatDate(bill.createdAt)} Time: ${_formatTime(bill.createdAt)}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Divider(),
              pw.Table(
                border: pw.TableBorder.symmetric(inside: const pw.BorderSide(color: PdfColors.grey300, width: 0.3)),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 2), child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 2), child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 2), child: pw.Text('Amt', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                  ...bill.items.map((CartItem item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 2), child: pw.Text(item.name, style: const pw.TextStyle(fontSize: 9))),
                        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 2), child: pw.Text('${item.quantity}', style: const pw.TextStyle(fontSize: 9))),
                        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 2), child: pw.Text(CurrencyFormatter.format(item.lineTotal), style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.right)),
                      ],
                    );
                  }),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(CurrencyFormatter.format(bill.subtotal), style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GST (${bill.gstRate}%)', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(CurrencyFormatter.format(bill.gstAmount), style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(CurrencyFormatter.format(bill.total), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                ],
              ),
              pw.Divider(),
              pw.Text('Payment: ${bill.paymentMethod}', style: const pw.TextStyle(fontSize: 10)),
              if (bill.customerName != null && bill.customerName!.isNotEmpty)
                pw.Text('Customer: ${bill.customerName}', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 8),
              pw.Text('Thank you! Visit again.', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/receipt_${bill.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  static String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}