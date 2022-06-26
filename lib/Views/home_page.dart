import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:henri_potier_app/Controllers/books_controller.dart';
import 'package:henri_potier_app/Controllers/offer_controller.dart';
import 'package:henri_potier_app/Helpers/snackbar.dart';
import 'package:henri_potier_app/Models/book_model.dart';
import 'package:henri_potier_app/Models/offer_model.dart';
import 'package:henri_potier_app/Models/order_model.dart';
import 'package:henri_potier_app/Models/reduction_model.dart';
import 'package:henri_potier_app/Views/book_details.dart';
import 'package:henri_potier_app/config.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? backButtonPressTime;
  List<Book> books = [];
  List<Book> allBooks = [];
  List<Order> orders = [];

  bool isLoading = true;
  final BookController bookController = BookController();
  final OfferController offerController = OfferController();
  bool expandMenu = false;
  @override
  void initState() {
    super.initState();
    fetchOrders();
    fetchBooks();
  }

  /*fetchOffers() {
    if (orders.isNotEmpty) {
      offerController.getOffers(orders).then((list) {
        print(list);
      });
    }
  }*/

  fetchOrders() {
    List<Order> _orders = [];
    List<dynamic> list = Hive.box('cart').values.toList();
    for (var item in list) {
      Order converted = Order.fromJson(jsonDecode(item));
      _orders.add(converted);
    }
    setState(() => orders = _orders);
  }

  fetchBooks() {
    bookController.getBooks().then((list) {
      if (list != null) {
        setState(() {
          books = list;
          allBooks = list;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ShowSnackBar().showSnackBar(
          context,
          "Something went wrong",
          duration: const Duration(seconds: 2),
          noAction: true,
        );
      }
    });
  }

  searchBooks(String value) {
    if (value.isNotEmpty) {
      setState(() {
        books = allBooks
            .where((book) =>
                book.title.toLowerCase().contains(value.toLowerCase()))
            .toList();
      });
    } else {
      setState(() {
        books = allBooks;
      });
    }
  }

  Future<bool> handleWillPop(BuildContext context) async {
    final now = DateTime.now();
    final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
        backButtonPressTime == null ||
            now.difference(backButtonPressTime!) > const Duration(seconds: 3);

    if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
      backButtonPressTime = now;
      ShowSnackBar().showSnackBar(
        context,
        "Press Back Again to Exit App",
        duration: const Duration(seconds: 2),
        noAction: true,
      );
      return false;
    }
    return true;
  }

  int getPosition(Order order) {
    int index = -1;
    for (var i = 0; i < orders.length; i++) {
      if (orders[i].id == order.id) {
        index = i;
      }
    }
    return index;
  }

  Widget _buildLargeCart(
      {required double containerHeight, required double totalOrders}) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 250,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              width: MediaQuery.of(context).size.width,
              height: containerHeight - 230,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Cart",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: orders.map((order) {
                        return Dismissible(
                          key: Key(order.id.toString()),
                          onDismissed: (direction) {
                            int index = getPosition(order);
                            Hive.box('cart').deleteAt(index);
                            orders.removeAt(index);
                            setState(() {});
                          },
                          direction: DismissDirection.horizontal,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            height: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: CachedNetworkImage(
                                    imageUrl: order.book!.cover,
                                    fit: BoxFit.cover,
                                    height: 60,
                                    width: 60,
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
                                const SizedBox(width: 5),
                                Text(
                                  "${order.quantity} x",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    order.book!.title,
                                    softWrap: false,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "${order.quantity! * order.book!.price}€",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            ),
            _buildBestPromotionContainer(
                list: orders, totalOrders: totalOrders),
            SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              height: 90,
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                width: MediaQuery.of(context).size.width - 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                    child: Text(
                  "Order",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Reduction getBestReduction(
      {required List<Offer> offers, required double totalOrders}) {
    Reduction percentageReduction = Reduction('percentage', totalOrders,
        "une réduction s'appliquant sur le prix de l'ensemble des livres.", 0);
    Reduction minusReduction = Reduction(
        'minus', totalOrders, "déduction directement applicable en caisse ", 0);
    Reduction sliceReduction =
        Reduction('slice', totalOrders, "remboursement par tranche d'achat", 0);

    for (Offer offer in offers) {
      switch (offer.type!) {
        case "percentage":
          double reduction = totalOrders * (offer.value! / 100);
          percentageReduction.result =
              totalOrders - reduction; //reduction pourcentage
          percentageReduction.description =
              "une réduction de ${offer.value!}% sur ensemble des livres.";
          percentageReduction.value = offer.value!;
          break;
        case "minus":
          minusReduction.result =
              totalOrders - offer.value!; //reduction directe
          minusReduction.description =
              "déduction de ${offer.value!}€ applicable en caisse ";
          minusReduction.value = offer.value!;
          break;
        case "slice":
          int nbreTranche =
              (totalOrders / offer.sliceValue!).round(); //tranche d'achat
          double reduction = (offer.value! * nbreTranche).toDouble();
          sliceReduction.result = totalOrders - reduction;
          sliceReduction.description =
              "${offer.value}€ par tranche de ${offer.sliceValue}€ d'achat";
          sliceReduction.value = offer.value!;
          break;
      }
    }

    Reduction bestReduction = [
      percentageReduction,
      minusReduction,
      sliceReduction
    ].reduce((a, b) => a.result < b.result ? a : b);

    /*print(
        "reductions :${[percentageReduction, minusReduction, sliceReduction]}");
    print("bestReduction :$bestReduction");*/
    return bestReduction;
  }

  Widget _buildBestPromotionContainer(
      {required List<Order> list, required double totalOrders}) {
    return list.isNotEmpty
        ? FutureBuilder(
            future: offerController.getOffers(list),
            builder:
                (BuildContext context, AsyncSnapshot<List<Offer>?> snapshot) {
              if (snapshot.hasData) {
                List<Offer> offers = snapshot.data!;
                Reduction bestReduction =
                    getBestReduction(offers: offers, totalOrders: totalOrders);

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      width: MediaQuery.of(context).size.width - 20,
                      height: 90,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            bestReduction.type == 'percentage'
                                ? Row(
                                    children: [
                                      Text(
                                        "${bestReduction.value}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 35,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        margin:
                                            const EdgeInsets.only(left: 2.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Text(
                                              "%",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "OFF",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            "Total :",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            totalOrders.toStringAsFixed(0) +
                                                "€",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            "A payer :",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            bestReduction.result
                                                    .toStringAsFixed(0) +
                                                "€",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                            Container(
                              height: 40,
                              width: 2,
                              color: Palette.primaryColor,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "La promotion la plus intéressante",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "${capitalize(bestReduction.description)} ",
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Montant a payer:",
                              style:
                                  TextStyle(fontSize: 23, color: Colors.white)),
                          Text("${bestReduction.result}€",
                              style: const TextStyle(
                                  fontSize: 23,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))
                        ]),
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Palette.primaryColor,
                  ),
                );
              }
            },
          )
        : Container();
  }

  Widget _buildSmallCart() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 75,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: orders.map((order) {
                  return Container(
                    margin: const EdgeInsets.only(left: 5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: CachedNetworkImage(
                        imageUrl: order.book!.cover,
                        fit: BoxFit.cover,
                        height: 60,
                        width: 60,
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
                  );
                }).toList(),
              ),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: Center(
              child: Text(
                "${orders.length}",
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                    color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height - 320;
    double totalOrders = 0;
    for (var order in orders) {
      totalOrders += (order.book!.price * order.quantity!);
    }

    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xffecebe7),
        title: const Text(
          "Bonjour, Henri Potier 👋",
          style: TextStyle(fontSize: 25, color: Colors.black),
        ),
        toolbarHeight: 70,
        elevation: 0,
      ),
      body: WillPopScope(
        onWillPop: () => handleWillPop(context),
        child: Stack(
          children: [
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Palette.primaryColor,
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0.0),
                            labelText: 'Recherche',
                            hintText: 'Saisir le nom du livre...',
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                            prefixIcon: const Icon(
                              CupertinoIcons.search,
                              color: Colors.black,
                              size: 18,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade200, width: 2),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onChanged: searchBooks,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        height: containerHeight,
                        child: MasonryGridView.count(
                          itemCount: books.length,
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BookDetails(
                                              book: books[index],
                                            ))).then((value) {
                                  if (value == "refresh") {
                                    fetchOrders();
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                decoration: BoxDecoration(
                                    color: const Color(0xfff5f5f5),
                                    borderRadius: BorderRadius.circular(10)),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Hero(
                                        tag: "image_${books[index].isbn}",
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl: books[index].cover,
                                            fit: BoxFit.cover,
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                CircularProgressIndicator(
                                              value: downloadProgress.progress,
                                              color: Palette.primaryColor,
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        books[index].title,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
            Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    setState(() => expandMenu = !expandMenu);
                  },
                  child: AnimatedContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 500),
                    height: expandMenu
                        ? MediaQuery.of(context).size.height - 250
                        : 150,
                    decoration: const BoxDecoration(
                        color: Palette.cardColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Stack(
                      children: [
                        Positioned(
                            top: 5,
                            left: MediaQuery.of(context).size.width / 2 - 35,
                            child: Container(
                              color: Colors.white,
                              height: 3,
                              width: 50,
                            )),
                        expandMenu
                            ? _buildLargeCart(
                                containerHeight: containerHeight,
                                totalOrders: totalOrders)
                            : _buildSmallCart(),
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
