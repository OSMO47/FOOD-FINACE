class Person {
  String name;
  double amountPaid;
  List<String> items;

  Person({
    required this.name,
    this.amountPaid = 0.0,
    List<String>? items,
  }) : items = items ?? [];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amountPaid': amountPaid,
      'items': items,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      name: map['name'],
      amountPaid: map['amountPaid'],
      items: List<String>.from(map['items']),
    );
  }
}
