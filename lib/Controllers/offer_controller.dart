import 'dart:convert';

import 'package:henri_potier_app/Models/offer_model.dart';
import 'package:henri_potier_app/Models/order_model.dart';
import 'package:henri_potier_app/config.dart';
import 'package:http/http.dart' as http;

class OfferController {
  Future<List<Offer>?> getOffers(List<Order> orders) async {
    String booksId = _getBooksId(orders);

    final response = await http
        .get(Uri.https(baseURL, "app/books/$booksId/commercialOffers"))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      List<Offer> offers = [];

      for (var item in body["offers"]) {
        Offer offer = Offer.fromJson(item);
        offers.add(offer);
      }
      return offers;
    } else {
      print("something went wrong");
      return null;
    }
  }

  String _getBooksId(List<Order> orders) {
    String booksId = "";
    for (int i = 0; i < orders.length; i++) {
      if (booksId.isEmpty) {
        booksId += orders[i].book!.isbn;
      } else if (i < orders.length) {
        booksId += "," + orders[i].book!.isbn;
      } else {
        booksId += orders[i].book!.isbn;
      }
    }
    return booksId;
  }
}
