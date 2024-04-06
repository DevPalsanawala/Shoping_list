import 'package:shopinglist/models/category.dart';

class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.date,
    required this.category,
  });

  final String id;
  final String name;
  final int quantity;
  final String date;
  final Category category;
}
