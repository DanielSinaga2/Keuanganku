import 'package:flutter/material.dart';

IconData getCategoryIcon(String category) {

  switch (category) {

    case "Food":
      return Icons.restaurant;

    case "Transport":
      return Icons.directions_car;

    case "Shopping":
      return Icons.shopping_bag;

    case "Salary":
      return Icons.attach_money;

    case "Entertainment":
      return Icons.movie;

    default:
      return Icons.category;
  }
}