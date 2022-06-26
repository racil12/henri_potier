class Book {
  final String isbn;
  final String title;
  final double price;
  final String cover;
  final List<String> synopsis;

  Book(this.isbn, this.title, this.price, this.cover, this.synopsis);

  Book.fromJson(Map<String, dynamic> json)
      : isbn = json['isbn'],
        title = json['title'],
        price = json["price"] is int
            ? (json['price'] as int).toDouble()
            : json['price'],
        cover = json['cover'],
        synopsis = json['synopsis'].cast<String>();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isbn'] = isbn;
    data['title'] = title;
    data['price'] = price;
    data['cover'] = cover;
    data['synopsis'] = synopsis;
    return data;
  }
}
