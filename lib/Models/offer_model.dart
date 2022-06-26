class Offer {
  String? type;
  int? value;
  int? sliceValue;

  Offer({this.type, this.value, this.sliceValue});

  Offer.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    value = json['value'];
    sliceValue = json['sliceValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['value'] = value;
    data['sliceValue'] = sliceValue;
    return data;
  }

  @override
  String toString() {
    return ('{type: $type, value: $value, sliceValue: $sliceValue}');
  }
}
