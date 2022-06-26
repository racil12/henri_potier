import 'package:henri_potier_app/Models/book_model.dart';

class Order {
  String? id;
  Book? book;
  int? quantity;
  DateTime? createdAt;

  Order({this.id, this.book, this.quantity, this.createdAt});

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    book = Book.fromJson(json['book']);
    quantity = json['quantity'];
    createdAt = DateTime.parse(json['createdAt']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['book'] = book!.toJson();
    data['quantity'] = quantity;
    data['createdAt'] = createdAt.toString();
    return data;
  }
}
