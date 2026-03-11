import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../services/pdf_service.dart';
import '../../services/ai_insight_service.dart'; // TAMBAHAN: Import AI Insight Service
import '../../models/transaction_model.dart';
import '../../models/budget_model.dart';
import '../transaction/add_transaction_page.dart';
import '../budget/add_budget_page.dart';
import '../../services/auth_service.dart';
import '../auth/login/login_page.dart';
import '../../utils/category_icons.dart';
import '../transaction/edit_transaction_page.dart';
import '../../providers/theme_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedMonth = DateTime.now().month;
  bool _isLoading = false;

  final pdfService = PdfService();
  final aiService = AiInsightService(); // TAMBAHAN: Instance AI Insight Service

  // Warna-warna untuk pie chart
  final List<Color> pieColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
  ];

  String getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final authService = AuthService();
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeProvider.isDark ? Colors.blue.shade900 : Colors.blue.shade700,
        foregroundColor: Colors.white,
        title: const Text(
          "Keuanganku",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Budget Icon Button
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddBudgetPage(),
                ),
              );
            },
            tooltip: 'Tambah Anggaran',
          ),

          // PDF Export Button
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              try {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                final snapshot = await firestoreService.getTransactions().first;
                
                Navigator.pop(context);

                await pdfService.generateReport(snapshot);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("PDF Report generated successfully"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error generating PDF: $e"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              }
            },
            tooltip: 'Export to PDF',
          ),

          // Theme Toggle Button
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
                tooltip: themeProvider.isDark ? 'Light Mode' : 'Dark Mode',
              );
            },
          ),

          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              setState(() => _isLoading = true);
              await authService.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: firestoreService.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: themeProvider.isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions found',
                    style: TextStyle(
                      fontSize: 18,
                      color: themeProvider.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          List<TransactionModel> transactions = snapshot.data!;

          /// FILTER BULAN
          transactions = transactions.where((t) {
            return t.date.month == selectedMonth;
          }).toList();

          double income = 0;
          double expense = 0;
          Map<String, double> categoryExpense = {};

          for (var t in transactions) {
            if (t.type == "income") {
              income += t.amount;
            } else {
              expense += t.amount;
              categoryExpense[t.category] =
                  (categoryExpense[t.category] ?? 0) + t.amount;
            }
          }

          double balance = income - expense;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            color: Colors.blue.shade700,
            backgroundColor: themeProvider.isDark ? Colors.grey.shade800 : Colors.white,
            child: CustomScrollView(
              slivers: [
                // Month Filter Sliver
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeProvider.isDark ? Colors.grey.shade800 : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedMonth,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: themeProvider.isDark ? Colors.white70 : Colors.blue.shade700,
                        ),
                        elevation: 16,
                        style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.isDark ? Colors.white70 : Colors.blue.shade700,
                        ),
                        dropdownColor: themeProvider.isDark ? Colors.grey.shade800 : Colors.white,
                        items: List.generate(12, (index) {
                          final month = index + 1;
                          return DropdownMenuItem(
                            value: month,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 18,
                                  color: themeProvider.isDark ? Colors.white70 : Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(getMonthName(month)),
                              ],
                            ),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            selectedMonth = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                // Balance Card Sliver
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: themeProvider.isDark
                            ? [Colors.blue.shade800, Colors.blue.shade900]
                            : [Colors.blue.shade700, Colors.blue.shade900],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Saldo",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                getMonthName(selectedMonth),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Rp ${balance.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildBalanceChip(
                                icon: Icons.arrow_upward,
                                label: "Pemasukan",
                                amount: income,
                                color: Colors.greenAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildBalanceChip(
                                icon: Icons.arrow_downward,
                                label: "Pengeluaran",
                                amount: expense,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Budget Section
                SliverToBoxAdapter(
                  child: StreamBuilder<List<BudgetModel>>(
                    stream: firestoreService.getBudgets(),
                    builder: (context, budgetSnapshot) {
                      if (!budgetSnapshot.hasData) {
                        return const SizedBox();
                      }

                      final budgets = budgetSnapshot.data!;
                      
                      if (budgets.isEmpty) {
                        return const SizedBox();
                      }

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Anggaran Bulanan",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: themeProvider.isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "${budgets.length} Anggaran",
                                    style: TextStyle(
                                      color: themeProvider.isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...budgets.map((budget) {
                            double spent = 0;

                            for (var t in transactions) {
                              if (t.category == budget.category && t.type == "expense") {
                                spent += t.amount;
                              }
                            }

                            double percent = spent / budget.limit;

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: themeProvider.isDark ? Colors.grey.shade800 : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        budget.category,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: themeProvider.isDark ? Colors.white70 : Colors.black87,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: percent > 0.8
                                              ? Colors.red.withOpacity(0.1)
                                              : Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          "${(percent * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            color: percent > 0.8
                                                ? Colors.red
                                                : Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Batas anggaran",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "Rp ${budget.limit.toStringAsFixed(0)}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: themeProvider.isDark ? Colors.white70 : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              "Dihabiskan",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "Rp ${spent.toStringAsFixed(0)}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: percent > 0.8
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Stack(
                                    children: [
                                      Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: themeProvider.isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: percent > 1 ? 1 : percent,
                                        child: Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: percent > 0.8
                                                  ? [Colors.red.shade400, Colors.red.shade700]
                                                  : [Colors.green.shade400, Colors.green.shade700],
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (percent > 0.8)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            size: 16,
                                            color: Colors.red.shade700,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            percent > 1 
                                                ? "⚠️ Budget exceeded!" 
                                                : "⚠️ Budget almost full",
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),

                // TAMBAHAN: AI Insight Section
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeProvider.isDark 
                          ? Colors.orange.shade900.withOpacity(0.3) 
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: themeProvider.isDark 
                            ? Colors.orange.shade800 
                            : Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        final insights = aiService.generateInsights(transactions);
                        
                        if (insights.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: themeProvider.isDark 
                                        ? Colors.orange.shade800 
                                        : Colors.orange.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: 16,
                                    color: themeProvider.isDark 
                                        ? Colors.white 
                                        : Colors.orange.shade800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "💡 Insight Pengeluaran",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.isDark 
                                        ? Colors.orange.shade200 
                                        : Colors.orange.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...insights.map(
                              (text) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "• ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: themeProvider.isDark 
                                            ? Colors.white70 
                                            : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        text,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: themeProvider.isDark 
                                              ? Colors.white70 
                                              : Colors.black87,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).toList(),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Stats Section
                if (categoryExpense.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Rincian Biaya",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: themeProvider.isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${categoryExpense.length} Kategori",
                              style: TextStyle(
                                color: themeProvider.isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Pie Chart Sliver
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: themeProvider.isDark ? Colors.grey.shade800 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: categoryExpense.entries
                                    .map((entry) {
                                  int index = categoryExpense.keys
                                      .toList()
                                      .indexOf(entry.key);
                                  return PieChartSectionData(
                                    value: entry.value,
                                    title: entry.key,
                                    radius: 50,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    color: pieColors[index % pieColors.length],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: categoryExpense.entries.map((entry) {
                              int index = categoryExpense.keys
                                  .toList()
                                  .indexOf(entry.key);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: pieColors[index % pieColors.length]
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: pieColors[index % pieColors.length]
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: pieColors[
                                            index % pieColors.length],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: pieColors[
                                            index % pieColors.length],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Recent Transactions Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Transaksi Terbaru",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        if (transactions.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              // Lihat semua transaksi
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: themeProvider.isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                            ),
                            child: const Text("Lihat semua"),
                          ),
                      ],
                    ),
                  ),
                ),

                // Transactions List dengan Swipe to Delete dan onTap untuk Edit
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final t = transactions[index];
                      return Dismissible(
                        key: Key(t.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        onDismissed: (direction) async {
                          await firestoreService.deleteTransaction(t.id);
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Transaksi berhasil dihapus"),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: themeProvider.isDark ? Colors.grey.shade800 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTransactionPage(
                                    transaction: t,
                                  ),
                                ),
                              );
                            },
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: t.type == "income"
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                getCategoryIcon(t.category),
                                color: t.type == "income"
                                    ? Colors.green
                                    : Colors.red,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              t.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: themeProvider.isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: themeProvider.isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    t.category,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: themeProvider.isDark ? Colors.white70 : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  t.type == "income" ? "Income" : "Expense",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: t.type == "income"
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: t.type == "income"
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${t.type == "expense" ? "- " : "+ "}Rp ${t.amount.toStringAsFixed(0)}",
                                style: TextStyle(
                                  color: t.type == "income"
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: transactions.length > 5
                        ? 5
                        : transactions.length,
                  ),
                ),

                // Empty State
                if (transactions.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 80,
                            color: themeProvider.isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada Transaksi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add your first transaction',
                            style: TextStyle(
                              color: themeProvider.isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTransactionPage(),
              ),
            );
          },
          backgroundColor: themeProvider.isDark ? Colors.blue.shade800 : Colors.blue.shade700,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildBalanceChip({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Rp ${amount.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}