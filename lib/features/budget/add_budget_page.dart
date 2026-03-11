import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../models/budget_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/theme_provider.dart';

class AddBudgetPage extends StatefulWidget {
  const AddBudgetPage({super.key});

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  final categoryController = TextEditingController();
  final limitController = TextEditingController();

  final firestoreService = FirestoreService();

  void saveBudget() async {
    final user = FirebaseAuth.instance.currentUser;

    final budget = BudgetModel(
      id: "",
      category: categoryController.text,
      limit: double.parse(limitController.text),
      userId: user!.uid,
    );

    await firestoreService.addBudget(budget);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tambah anggaran",
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
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 40,
                    color: isDark ? Colors.blue.shade200 : Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),

                // Info Text
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Tetapkan anggaran bulanan Anda",
                    style: TextStyle(
                      color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                      fontSize: 14,
                    ),
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
                          // Category Field
                          TextField(
                            controller: categoryController,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: "Kategori",
                              labelStyle: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                              hintText: "e.g., Food, Transport, Shopping",
                              hintStyle: TextStyle(
                                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
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
                          const SizedBox(height: 16),

                          // Budget Limit Field
                          TextField(
                            controller: limitController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: "batas anggaran",
                              labelStyle: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                              hintText: "1000000",
                              hintStyle: TextStyle(
                                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                              ),
                              prefixIcon: Icon(Icons.money, size: 20,
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
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Save Button
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
                    onPressed: saveBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Hemat Anggaran",
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
    categoryController.dispose();
    limitController.dispose();
    super.dispose();
  }
}