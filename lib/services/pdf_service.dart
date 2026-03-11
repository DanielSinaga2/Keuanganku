import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../models/transaction_model.dart';

class PdfService {

  Future<void> generateReport(List<TransactionModel> transactions) async {

    final pdf = pw.Document();

    double totalPemasukan = 0;
    double totalPengeluaran = 0;

    for (var t in transactions) {

      if (t.type == "income") {
        totalPemasukan += t.amount;
      } else {
        totalPengeluaran += t.amount;
      }

    }

    final saldo = totalPemasukan - totalPengeluaran;

    final now = DateTime.now();

    pdf.addPage(

      pw.Page(

        pageFormat: PdfPageFormat.a4,

        build: (context) {

          return pw.Column(

            crossAxisAlignment: pw.CrossAxisAlignment.start,

            children: [

              /// HEADER
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                color: PdfColors.blue,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [

                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [

                        pw.Text(
                          "Keuanganku",
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),

                        pw.Text(
                          "Laporan Keuangan",
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                          ),
                        ),

                      ],
                    ),

                    pw.Text(
                      "${now.day}-${now.month}-${now.year}",
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                      ),
                    )

                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              /// RINGKASAN
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [

                  summaryCard(
                    "Total Pemasukan",
                    totalPemasukan,
                    PdfColors.green,
                  ),

                  summaryCard(
                    "Total Pengeluaran",
                    totalPengeluaran,
                    PdfColors.red,
                  ),

                  summaryCard(
                    "Saldo",
                    saldo,
                    PdfColors.blue,
                  ),

                ],
              ),

              pw.SizedBox(height: 30),

              pw.Text(
                "Daftar Transaksi",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              /// HEADER TABLE
              pw.Container(
                color: PdfColors.grey300,
                child: pw.Row(
                  children: [

                    tableHeader("Judul", 3),
                    tableHeader("Kategori", 2),
                    tableHeader("Jumlah", 2),

                  ],
                ),
              ),

              /// DATA TRANSAKSI
              ...transactions.map(

                (t) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 6,
                  ),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: PdfColors.grey,
                      ),
                    ),
                  ),
                  child: pw.Row(
                    children: [

                      tableCell(t.title, 3),

                      tableCell(t.category, 2),

                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          "${t.type == "expense" ? "-" : "+"}Rp ${t.amount.toStringAsFixed(0)}",
                          style: pw.TextStyle(
                            color: t.type == "expense"
                                ? PdfColors.red
                                : PdfColors.green,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

              ),

              pw.Spacer(),

              /// FOOTER
              pw.Center(
                child: pw.Text(
                  "Laporan dibuat oleh aplikasi Keuanganku",
                  style: const pw.TextStyle(
                    color: PdfColors.grey,
                  ),
                ),
              )

            ],

          );

        },

      ),

    );

    final directory = await getApplicationDocumentsDirectory();

    final file = File("${directory.path}/laporan_keuangan.pdf");

    await file.writeAsBytes(await pdf.save());

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "laporan_keuangan.pdf",
    );

  }

  /// CARD RINGKASAN
  pw.Widget summaryCard(String title, double amount, PdfColor color) {

    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [

          pw.Text(title),

          pw.SizedBox(height: 5),

          pw.Text(
            "Rp ${amount.toStringAsFixed(0)}",
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          )

        ],
      ),
    );

  }

  /// HEADER TABLE
  pw.Widget tableHeader(String text, int flex) {

    return pw.Expanded(
      flex: flex,
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );

  }

  /// ISI TABLE
  pw.Widget tableCell(String text, int flex) {

    return pw.Expanded(
      flex: flex,
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(text),
      ),
    );

  }

}