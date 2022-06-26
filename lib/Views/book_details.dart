import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:henri_potier_app/Models/book_model.dart';
import 'package:henri_potier_app/Models/order_model.dart';
import 'package:henri_potier_app/config.dart';
import 'package:hive/hive.dart';

class BookDetails extends StatefulWidget {
  final Book book;
  const BookDetails({Key? key, required this.book}) : super(key: key);

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  int _counter = 1;

  addToCart() {
    var box = Hive.box('cart');
    Order order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        book: widget.book,
        quantity: _counter,
        createdAt: DateTime.now());

    box.add(jsonEncode(order.toJson()));
    Navigator.pop(context, 'refresh');
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    int index = -1;

    var orders = Hive.box('cart').values.toList();

    for (var i = 0; i < orders.length; i++) {
      Order order = Order.fromJson(jsonDecode(orders[i]));
      if (order.book!.isbn == widget.book.isbn) {
        index = i;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: Text(widget.book.title),
        backgroundColor: Palette.cardColor,
      ),
      body: Stack(children: [
        RefreshIndicator(
          backgroundColor: Palette.backgroundColor,
          color: Palette.primaryColor,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: Hero(
                      tag: "image_${widget.book.isbn}",
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: CachedNetworkImage(
                          imageUrl: widget.book.cover,
                          height: size.height / 2,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                            value: downloadProgress.progress,
                            color: Palette.primaryColor,
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.book.title,
                    style: const TextStyle(
                        fontSize: 27, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 120,
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.black87)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    if (_counter > 1) {
                                      setState(() => _counter--);
                                    }
                                  },
                                  icon: const Icon(CupertinoIcons.minus)),
                              Text("$_counter"),
                              IconButton(
                                icon: const Icon(CupertinoIcons.add),
                                onPressed: () {
                                  setState(() => _counter++);
                                },
                              ),
                            ]),
                      ),
                      Text(
                        "${widget.book.price * _counter}€",
                        style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "A propos de ce livre",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: widget.book.synopsis.map((synopsis) {
                      return Text(
                        synopsis,
                        style: const TextStyle(fontSize: 20),
                      );
                    }).toList(),
                  ),
                  const SizedBox(
                    height: 100,
                  )
                ]),
          ),
        )
      ]),
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Palette.cardColor,
          onPressed: index == -1
              ? addToCart
              : () {
                  Hive.box('cart').deleteAt(index);
                  Navigator.pop(context, 'refresh');
                },
          label: Row(
            children: [
              index == -1
                  ? const Icon(CupertinoIcons.cart)
                  : const Icon(CupertinoIcons.trash),
              const SizedBox(width: 10),
              index == -1
                  ? const Text("Ajouter au panier")
                  : const Text("Supprimer du panier")
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
