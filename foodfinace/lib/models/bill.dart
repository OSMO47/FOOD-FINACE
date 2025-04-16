import 'package:bill_splitting_app/models/person.dart';
import 'package:bill_splitting_app/models/food_item.dart';

class Bill {
  List<Person> people;
  List<FoodItem> items;
  String? shareLink;

  Bill({
    List<Person>? people,
    List<FoodItem>? items,
    this.shareLink,
  })  : people = people ?? [],
        items = items ?? [];

  int get numberOfPeople => people.length;

  double get totalAmount {
    double total = 0;
    for (var item in items) {
      total += item.price;
    }
    return total;
  }

  void addPerson(Person person) {
    people.add(person);
  }

  void addItem(FoodItem item) {
    items.add(item);
    _updatePersonItems(item);
  }

  void _updatePersonItems(FoodItem item) {
    for (var personName in item.sharedBy) {
      final personIndex = people.indexWhere((p) => p.name == personName);
      if (personIndex != -1) {
        people[personIndex].items.add(item.name);
      }
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'people': people.map((p) => p.toMap()).toList(),
      'items': items.map((i) => i.toMap()).toList(),
      'shareLink': shareLink,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      people: (map['people'] as List).map((p) => Person.fromMap(p)).toList(),
      items: (map['items'] as List).map((i) => FoodItem.fromMap(i)).toList(),
      shareLink: map['shareLink'],
    );
  }

  void generateShareLink() {
    // In a real app, this would generate a unique link
    shareLink = 'https://phpstack-988892-3470693.cloudwaysapps.com/share/${DateTime.now().millisecondsSinceEpoch}';
  }
}
