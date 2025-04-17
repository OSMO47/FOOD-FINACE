import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import '../models/person.dart';
import '../models/item.dart';
import '../widgets/calculator_widget.dart';
import '../widgets/item_detail_dialog.dart';
import 'receipt_screen.dart';
import 'edit_profile_screen.dart'; // <-- Import หน้า Edit Profile
import 'login_screen.dart'; // <-- Import หน้า Login สำหรับ Logout
import '../utils/auth_helper.dart'; // <-- Import AuthHelper สำหรับ Logout และ Get User
import '../models/user.dart'; // <-- Import User Model

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final List<Person> _people = [];
  final List<Item> _items = [];
  double _totalAmount = 0.0;
  Map<int, double> _individualShares = {};
  User? _currentUser; // <-- State สำหรับเก็บข้อมูล User ที่ login อยู่

  final TextEditingController _newPersonNameController = TextEditingController();
  final TextEditingController _newItemNameController = TextEditingController();
  final TextEditingController _newItemPriceController = TextEditingController(text: '0');

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _calculateTotal();
    _loadCurrentUser(); // <-- โหลดข้อมูล User ตอนเริ่มหน้า
  }

  // โหลดข้อมูลผู้ใช้ปัจจุบัน
  Future<void> _loadCurrentUser() async {
    final user = await AuthHelper.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  void dispose() {
    _newPersonNameController.dispose();
    _newItemNameController.dispose();
    _newItemPriceController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    double total = _items.fold(0.0, (sum, item) => sum + item.price);
    if (mounted) {
      setState(() {
        _totalAmount = total;
        _individualShares = {};
      });
    }
  }

  void _addPerson() {
    final String name = _newPersonNameController.text.trim();
    if (name.isEmpty) return;

    final newPerson = Person(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
    );

    setState(() {
      _people.add(newPerson);
       _individualShares = {};
    });
    _newPersonNameController.clear();
    FocusScope.of(context).unfocus();
  }

  void _addItem() {
    final String name = _newItemNameController.text.trim();
    final double? price = double.tryParse(_newItemPriceController.text);

    if (name.isEmpty || price == null || price < 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกชื่อและราคาที่ถูกต้อง')),
      );
      return;
    }

    final newItem = Item(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      price: price,
      payerIds: [],
    );

    setState(() {
      _items.add(newItem);
    });
    _newItemNameController.clear();
    _newItemPriceController.text = '0';
    _calculateTotal();
    if (!mounted) return;
    FocusScope.of(context).unfocus();
  }

  void _handleCalculatorValue(double value) {
    _newItemPriceController.text = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }

  void _copyShareLink() {
    final shareText = "รายละเอียดบิล:\nคน: ${_people.map((p) => p.name).join(', ')}\nรายการ: ${_items.map((i) => '${i.name} (${i.price.toStringAsFixed(2)})').join(', ')}\nรวม: ${_totalAmount.toStringAsFixed(2)}";
    Clipboard.setData(ClipboardData(text: shareText)).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รายละเอียดบิลถูกคัดลอกแล้ว!')),
      );
    });
  }

   void _showCalculatorDialog() {
    final currentPrice = double.tryParse(_newItemPriceController.text) ?? 0.0;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: CalculatorWidget(
          initialValue: currentPrice,
          onValue: (value) {
            _handleCalculatorValue(value);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

   void _showAddItemDialog() {
    _newItemNameController.clear();
    _newItemPriceController.text = '0';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('เพิ่มรายการ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newItemNameController,
              decoration: const InputDecoration(
                hintText: 'ชื่อรายการ',
                prefixIcon: Icon(Icons.fastfood),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newItemPriceController,
                    decoration: const InputDecoration(
                      hintText: 'ราคา',
                       prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.calculate),
                  onPressed: () {
                     _showCalculatorDialog();
                  },
                  tooltip: 'เครื่องคิดเลข',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              _addItem();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('เพิ่ม'),
          ),
        ],
      ),
    );
  }

  void _showItemDetailDialog(Item item) {
    showDialog(
      context: context,
      builder: (context) => ItemDetailDialog(
        item: item,
        people: _people,
        onSavePayers: (updatedPayerIds) {
          setState(() {
            final itemIndex = _items.indexWhere((i) => i.id == item.id);
            if (itemIndex != -1) {
              _items[itemIndex].payerIds = updatedPayerIds;
               _individualShares = {};
            }
          });
        },
        onDeleteItem: () {
          setState(() {
            _items.removeWhere((i) => i.id == item.id);
            _calculateTotal();
          });
        },
      ),
    );
  }

  void _calculateShares() {
     _individualShares = {};
     if (_people.isEmpty) return;

     for (var person in _people) {
       _individualShares[person.id] = 0.0;
     }

     for (var item in _items) {
       if (item.payerIds.isNotEmpty) {
         double pricePerPayer = item.price / item.payerIds.length;
         for (var personId in item.payerIds) {
           if (_individualShares.containsKey(personId)) {
             _individualShares[personId] = (_individualShares[personId] ?? 0.0) + pricePerPayer;
           }
         }
       }
     }
     setState(() {});
  }

  void _navigateToReceipt() {
    _calculateShares();
    if (_items.isEmpty || _people.isEmpty || _individualShares.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเพิ่มรายการและคนจ่าย และคำนวณยอดก่อนดูใบเสร็จ')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptScreen(
          items: _items,
          people: _people,
          individualShares: _individualShares,
          totalAmount: _totalAmount,
        ),
      ),
    );
  }

  // จัดการการ Logout
  Future<void> _handleLogout() async {
    await AuthHelper.logoutUser();
    if (mounted) {
      // กลับไปหน้า Login และลบทุกหน้าก่อนหน้าออกจาก stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false, // ลบทุก route
      );
    }
  }

  // นำทางไปหน้าแก้ไขโปรไฟล์
  void _navigateToEditProfile() {
    if (_currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileScreen(currentUser: _currentUser!),
        ),
      ).then((_) {
        // Optional: โหลดข้อมูล User ใหม่หลังจากกลับมาจากหน้าแก้ไข
        _loadCurrentUser();
      });
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถโหลดข้อมูลผู้ใช้ปัจจุบันได้')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // แสดง Username ใน Title
        title: Text('สวัสดี, ${_currentUser?.username ?? "ผู้ใช้"}'),
        actions: [ // เพิ่มปุ่มเมนู (PopupMenuButton)
          PopupMenuButton<String>(
            onSelected: (String result) {
              // ตรวจสอบค่าที่เลือกจากเมนู
              switch (result) {
                case 'edit_profile':
                  _navigateToEditProfile(); // เรียกฟังก์ชันไปหน้าแก้ไข
                  break;
                case 'logout':
                  _handleLogout(); // เรียกฟังก์ชัน Logout
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              // เมนูแก้ไขข้อมูล
              const PopupMenuItem<String>(
                value: 'edit_profile',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('แก้ไขข้อมูลส่วนตัว'),
                ),
              ),
              const PopupMenuDivider(), // เส้นคั่นเมนู
              // เมนูออกจากระบบ
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
            icon: const Icon(Icons.account_circle), // ไอคอนรูปโปรไฟล์
          ),
        ],
        bottom: TabBar( // TabBar อยู่ที่ bottom ของ AppBar
          controller: _tabController,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt),
                  SizedBox(width: 8),
                  Text('รายการ'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people),
                  SizedBox(width: 8),
                  Text('คนจ่าย & สรุป'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildItemsTab(context),
          _buildPeopleAndSummaryTab(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'เพิ่มรายการ',
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- ไม่ต้องแก้ไข _buildHeaderInfo ---
  Widget _buildHeaderInfo(String label, String value) {
    // ฟังก์ชันนี้ถูกย้ายไปใช้ใน AppBar แล้ว ไม่ได้ใช้ใน Tab อีก
    // แต่เก็บไว้เผื่อใช้งานส่วนอื่นได้
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  // --- ไม่ต้องแก้ไข _buildItemsTab ---
  Widget _buildItemsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _newItemNameController,
            decoration: const InputDecoration(
              hintText: 'ระบุชื่อรายการ',
              prefixIcon: Icon(Icons.receipt_long),
            ),
             textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newItemPriceController,
                  decoration: const InputDecoration(
                    hintText: 'ราคา',
                    prefixIcon: Icon(Icons.price_change),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                   inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                   textInputAction: TextInputAction.done,
                   onSubmitted: (_) => _addItem(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.calculate_outlined),
                onPressed: _showCalculatorDialog,
                tooltip: 'เครื่องคิดเลข',
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
             icon: const Icon(Icons.add_shopping_cart),
             label: const Text('เพิ่มรายการ'),
             onPressed: _addItem,
             style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            label: const Text('ล้างรายชื่อคนจ่ายทั้งหมด', style: TextStyle(color: Colors.red)),
            onPressed: () {
               setState(() {
                 for (var item in _items) {
                   item.payerIds.clear();
                 }
                 _individualShares = {};
               });
               if (!mounted) return;
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('รายชื่อคนจ่ายทั้งหมดถูกล้างแล้ว')),
               );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('แชร์: '),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                   decoration: BoxDecoration(
                     border: Border.all(color: Colors.grey),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: const Text(
                     "กดปุ่มคัดลอกเพื่อแชร์",
                     overflow: TextOverflow.ellipsis,
                     maxLines: 1,
                     style: TextStyle(color: Colors.grey),
                   ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: _copyShareLink,
                tooltip: 'คัดลอกรายละเอียด',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text("รายการทั้งหมด:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          if (_items.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("ยังไม่มีรายการ", style: TextStyle(color: Colors.grey)),
            ))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                int payerCount = item.payerIds.length;
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('จ่าย ${payerCount} คน'),
                  trailing: Text(item.price.toStringAsFixed(2)),
                  onTap: () {
                     _showItemDetailDialog(item);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  // --- ไม่ต้องแก้ไข _buildPeopleAndSummaryTab มากนัก ---
  Widget _buildPeopleAndSummaryTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           const Text("เพิ่มคนจ่าย", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
           const SizedBox(height: 8),
           TextField(
             controller: _newPersonNameController,
             decoration: const InputDecoration(
               hintText: 'ชื่อคนจ่าย',
               prefixIcon: Icon(Icons.person_add_alt_1),
             ),
             textInputAction: TextInputAction.done,
             onSubmitted: (_) => _addPerson(),
           ),
           const SizedBox(height: 10),
           ElevatedButton.icon(
             icon: const Icon(Icons.add),
             label: const Text('เพิ่มคน'),
             onPressed: _addPerson,
           ),
           const SizedBox(height: 24),

           Row(
             children: [
               const Icon(Icons.group, color: Colors.grey),
               const SizedBox(width: 8),
               Text(
                 'รายชื่อคนจ่าย (${_people.length} คน)',
                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
               ),
             ],
           ),
           const Divider(),
           if (_people.isEmpty)
             const Center(child: Padding(
               padding: EdgeInsets.symmetric(vertical: 20.0),
               child: Text("ยังไม่มีคนจ่าย", style: TextStyle(color: Colors.grey)),
             ))
           else
             Wrap(
               spacing: 8.0,
               runSpacing: 4.0,
               children: _people.map((person) {
                 return Chip(
                   avatar: CircleAvatar(child: Text(person.name.isNotEmpty ? person.name[0].toUpperCase() : '?')),
                   label: Text(person.name),
                   onDeleted: () {
                     setState(() {
                       _people.remove(person);
                       for (var item in _items) {
                         item.payerIds.remove(person.id);
                       }
                       _calculateTotal();
                     });
                   },
                   deleteIconColor: Colors.redAccent,
                 );
               }).toList(),
             ),
           const SizedBox(height: 32),

           ElevatedButton.icon(
             icon: const Icon(Icons.receipt_long),
             label: const Text('ดูรายละเอียดใบเสร็จ'),
             onPressed: (_items.isEmpty || _people.isEmpty) ? null : _navigateToReceipt,
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.green,
               foregroundColor: Colors.white,
               padding: const EdgeInsets.symmetric(vertical: 14),
               textStyle: const TextStyle(fontSize: 16)
             ),
           ),
           const SizedBox(height: 24),
        ],
      ),
    );
  }
}
