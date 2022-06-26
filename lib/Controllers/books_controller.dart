import 'dart:convert';

import 'package:henri_potier_app/Models/book_model.dart';
import 'package:henri_potier_app/config.dart';
import 'package:http/http.dart' as http;

class BookController {
  Future<List<Book>?> getBooks() async {
    final response = await http
        .get(Uri.https(baseURL, "app/books/"))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      List<Book> books = [];

      for (var item in body) {
        Book book = Book.fromJson(item);
        books.add(book);
      }
      return books;
    } else {
      logger.d("something went wrong");
      return null;
    }
  }
}
