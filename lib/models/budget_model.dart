class BudgetModel {

  final String id;
  final String category;
  final double limit;
  final String userId;

  BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      "category": category,
      "limit": limit,
      "userId": userId,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map, String id) {
    return BudgetModel(
      id: id,
      category: map["category"],
      limit: (map["limit"]).toDouble(),
      userId: map["userId"],
    );
  }
}