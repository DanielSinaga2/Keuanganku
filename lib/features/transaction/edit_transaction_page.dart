import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/theme_provider.dart';

class EditTransactionPage extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionPage({super.key, required this.transaction});

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String type = "expense";
  String category = "Food";

  final firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();

    titleController.text = widget.transaction.title;
    amountController.text = widget.transaction.amount.toString();
    noteController.text = widget.transaction.note;

    type = widget.transaction.type;
    category = widget.transaction.category;
  }

  void updateTransaction() async {
    final updated = TransactionModel(
      id: widget.transaction.id,
      title: titleController.text,
      amount: double.parse(amountController.text),
      type: type,
      category: category,
      date: widget.transaction.date,
      note: noteController.text,
      userId: widget.transaction.userId,
    );

    await firestoreService.updateTransaction(updated);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Transaksi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.blue.shade900 : Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.grey.shade900, Colors.grey.shade800]
                : [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (type == "income" ? Colors.green : Colors.blue).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    type == "income" ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 40,
                    color: type == "income" ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 20),

                // Type Selector Card
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              type = "expense";
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: type == "expense"
                                  ? Colors.red
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                "Pengeluaran",
                                style: TextStyle(
                                  color: type == "expense"
                                      ? Colors.white
                                      : (isDark ? Colors.grey.shade400 : Colors.grey),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              type = "income";
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: type == "income"
                                  ? Colors.green
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                "Pemasukkan",
                                style: TextStyle(
                                  color: type == "income"
                                      ? Colors.white
                                      : (isDark ? Colors.grey.shade400 : Colors.grey),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Form Fields - Expanded
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Title Field
                          TextField(
                            controller: titleController,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: "Judul",
                              labelStyle: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                              hintText: "Masukkan Judul",
                              hintStyle: TextStyle(
                                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                              ),
                              prefixIcon: Icon(Icons.title, size: 20, 
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.blue.shade700,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Amount Field
                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: "Jumlah",
                              labelStyle: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                              hintText: "0",
                              hintStyle: TextStyle(
                                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                              ),
                              prefixIcon: Icon(Icons.attach_money, size: 20,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.blue.shade700,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Category Dropdown
                          DropdownButtonFormField<String>(
                            value: category,
                            dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: "Kategori",
                              labelStyle: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                              prefixIcon: Icon(Icons.category, size: 20,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: "Food", child: Text("Food")),
                              DropdownMenuItem(value: "Transport", child: Text("Transport")),
                              DropdownMenuItem(value: "Shopping", child: Text("Shopping")),
                              DropdownMenuItem(value: "Entertainment", child: Text("Entertainment")),
                              DropdownMenuItem(value: "Bills", child: Text("Bills")),
                              DropdownMenuItem(value: "Healthcare", child: Text("Healthcare")),
                              DropdownMenuItem(value: "Education", child: Text("Education")),
                              DropdownMenuItem(value: "Salary", child: Text("Salary")),
                              DropdownMenuItem(value: "Other", child: Text("Other")),
                            ],
                            onChanged: (value) {
                              setState(() {
                                category = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          // Note Field
                          TextField(
                            controller: noteController,
                            maxLines: 3,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: "Catatan",
                              labelStyle: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                              hintText: "Masukkan catatan anda...",
                              hintStyle: TextStyle(
                                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                              ),
                              prefixIcon: Icon(Icons.note, size: 20,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.blue.shade700,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Update Button
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Colors.blue.shade800, Colors.blue.shade900]
                          : [Colors.blue.shade600, Colors.blue.shade800],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: updateTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Perbarui Transaksi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }
}