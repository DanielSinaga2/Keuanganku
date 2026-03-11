class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final DateTime date;
  final String note;
  final String userId;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.note,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "amount": amount,
      "type": type,
      "category": category,
      "date": date,
      "note": note,
      "userId": userId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      title: map["title"],
      amount: (map["amount"]).toDouble(),
      type: map["type"],
      category: map["category"],
      date: (map["date"]).toDate(),
      note: map["note"] ?? "",
      userId: map["userId"],
    );
  }
}