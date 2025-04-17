class Person {
  final int id; 
  final String name; 
  double amount; 

  Person({required this.id, required this.name, this.amount = 0.0});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
