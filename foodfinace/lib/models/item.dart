class Item {
  final int id; 
  final String name; 
  double price; 
  List<int> payerIds; 

  Item({
    required this.id,
    required this.name,
    required this.price,
    List<int>? payerIds, 
  }) : payerIds = payerIds ?? []; 
}
