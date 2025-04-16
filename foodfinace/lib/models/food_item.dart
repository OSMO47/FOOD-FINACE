class FoodItem {
  String name;
  double price;
  List<String> sharedBy;

  FoodItem({
    required this.name,
    required this.price,
    List<String>? sharedBy,
  }) : sharedBy = sharedBy ?? [];

  double getPricePerPerson() {
    if (sharedBy.isEmpty) return 0;
    return price / sharedBy.length;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'sharedBy': sharedBy,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'],
      price: map['price'],
      sharedBy: List<String>.from(map['sharedBy']),
    );
  }
}
