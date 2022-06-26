class Reduction {
  String type;
  int value;
  double result;
  String description;
  Reduction(
    this.type,
    this.result,
    this.description,
    this.value,
  );

  @override
  String toString() {
    return ('{type: $type, result: $result}');
  }
}
