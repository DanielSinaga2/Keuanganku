import '../models/transaction_model.dart';

class AiInsightService {

  List<String> generateInsights(List<TransactionModel> transactions) {

    List<String> insights = [];

    if (transactions.isEmpty) {
      insights.add("Belum ada transaksi bulan ini.");
      return insights;
    }

    double totalExpense = 0;

    Map<String, double> categoryExpense = {};

    for (var t in transactions) {

      if (t.type == "expense") {

        totalExpense += t.amount;

        categoryExpense[t.category] =
            (categoryExpense[t.category] ?? 0) + t.amount;

      }

    }

    if (totalExpense == 0) {
      insights.add("Belum ada pengeluaran bulan ini.");
      return insights;
    }

    /// kategori terbesar
    String topCategory = "";
    double topAmount = 0;

    categoryExpense.forEach((category, amount) {

      if (amount > topAmount) {
        topAmount = amount;
        topCategory = category;
      }

    });

    insights.add(
        "Pengeluaran terbesar bulan ini adalah kategori $topCategory.");

    insights.add(
        "Anda menghabiskan Rp${topAmount.toStringAsFixed(0)} untuk $topCategory.");

    double percent = (topAmount / totalExpense) * 100;

    if (percent > 40) {

      insights.add(
          "⚠️ Kategori $topCategory mengambil ${percent.toStringAsFixed(0)}% dari total pengeluaran.");

      insights.add(
          "Pertimbangkan untuk mengurangi pengeluaran di kategori ini.");

    }

    if (totalExpense > 2000000) {

      insights.add(
          "Total pengeluaran bulan ini cukup tinggi. Coba cek kembali kebutuhan utama.");

    }

    if (categoryExpense.length >= 5) {

      insights.add(
          "Anda memiliki banyak kategori pengeluaran. Pertimbangkan menyederhanakan budget.");

    }

    return insights;

  }

}