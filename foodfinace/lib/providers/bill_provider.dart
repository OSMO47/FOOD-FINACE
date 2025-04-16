import 'package:flutter/foundation.dart';
import 'package:bill_splitting_app/models/bill.dart';
import 'package:bill_splitting_app/models/person.dart';
import 'package:bill_splitting_app/models/food_item.dart';

class BillProvider with ChangeNotifier {
  Bill _bill = Bill();

  Bill get bill => _bill;
  List<Person> get people => _bill.people;
  List<FoodItem> get items => _bill.items;
  int get numberOfPeople => _bill.numberOfPeople;
  double get totalAmount => _bill.totalAmount;
  String? get shareLink => _bill.shareLink;

  void addPerson(String name) {
    if (name.trim().isEmpty) return;
    
    // Check if person already exists
    if (_bill.people.any((p) => p.name == name)) return;
    
    final person = Person(name: name);
    _bill.addPerson(person);
    notifyListeners();
  }

  void addFoodItem(String name, double price, List<String> sharedBy) {
    if (name.trim().isEmpty || price <= 0) return;
    
    final item = FoodItem(
      name: name,
      price: price,
      sharedBy: sharedBy,
    );
    
    _bill.addItem(item);
    notifyListeners();
  }

  void generateShareLink() {
    _bill.generateShareLink();
    notifyListeners();
  }

  void reset() {
    _bill = Bill();
    notifyListeners();
  }
}
