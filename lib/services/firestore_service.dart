import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';
import '../models/budget_model.dart';

class FirestoreService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ==========================
  /// ADD TRANSACTION
  /// ==========================
  Future<void> addTransaction(TransactionModel transaction) async {

    await _db.collection("transactions").add(
      transaction.toMap(),
    );

  }

  /// ==========================
  /// UPDATE TRANSACTION
  /// ==========================
  Future<void> updateTransaction(TransactionModel transaction) async {

    await _db
        .collection("transactions")
        .doc(transaction.id)
        .update(transaction.toMap());

  }

  /// ==========================
  /// DELETE TRANSACTION
  /// ==========================
  Future<void> deleteTransaction(String id) async {

    await _db.collection("transactions").doc(id).delete();

  }

  /// ==========================
  /// GET TRANSACTIONS
  /// ==========================
  Stream<List<TransactionModel>> getTransactions() {

    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _db
        .collection("transactions")
        .where("userId", isEqualTo: user.uid)
        .orderBy("date", descending: true)
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return TransactionModel.fromMap(
          doc.data(),
          doc.id,
        );

      }).toList();

    });

  }

  /// ==========================
  /// ADD BUDGET
  /// ==========================
  Future<void> addBudget(BudgetModel budget) async {

    await _db.collection("budgets").add(
      budget.toMap(),
    );

  }

  /// ==========================
  /// GET BUDGETS
  /// ==========================
  Stream<List<BudgetModel>> getBudgets() {

    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _db
        .collection("budgets")
        .where("userId", isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return BudgetModel.fromMap(
          doc.data(),
          doc.id,
        );

      }).toList();

    });

  }

}