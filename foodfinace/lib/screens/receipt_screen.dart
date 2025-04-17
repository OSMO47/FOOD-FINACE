import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/person.dart';

class ReceiptScreen extends StatelessWidget {
  final List<Item> items; // รายการอาหารทั้งหมด
  final List<Person> people; // รายชื่อคนทั้งหมด
  final Map<int, double>
      individualShares; // ยอดรวมที่แต่ละคนต้องจ่าย (คำนวณจาก HomeScreen)
  final double totalAmount; // ยอดรวมทั้งหมด

  const ReceiptScreen({
    super.key,
    required this.items,
    required this.people,
    required this.individualShares,
    required this.totalAmount,
  });

  // ฟังก์ชันช่วยค้นหาชื่อคนจาก ID
  String _getPersonName(int personId) {
    try {
      return people.firstWhere((p) => p.id == personId).name;
    } catch (e) {
      return 'ไม่พบชื่อ'; // กรณีไม่เจอ ID (ไม่ควรเกิดขึ้น)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดใบเสร็จ'),
        backgroundColor: Colors.grey[700], // สีเดียวกับ header เดิม
        foregroundColor: Colors.white,
      ),
      body: ListView(
        // ใช้ ListView เพื่อให้เลื่อนได้
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- ส่วนสรุปยอดรวม ---
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'ยอดรวมทั้งหมด',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${totalAmount.toStringAsFixed(2)} บาท',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${items.length} รายการ / ${people.length} คน',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- ส่วนรายละเอียดแต่ละรายการ ---
          Text(
            'รายละเอียดตามรายการ',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          if (items.isEmpty)
            const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text("ไม่มีรายการ", style: TextStyle(color: Colors.grey)),
            ))
          else
            // สร้าง Widget สำหรับแต่ละรายการ
            ...items.map((item) {
              final bool hasPayers = item.payerIds.isNotEmpty;
              final double amountPerPayer =
                  hasPayers ? (item.price / item.payerIds.length) : 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ชื่อรายการและราคา
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            '${item.price.toStringAsFixed(2)} บาท',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(),
                      // รายชื่อคนจ่ายสำหรับรายการนี้
                      if (!hasPayers)
                        const Text('  - ไม่มีผู้จ่ายสำหรับรายการนี้',
                            style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic))
                      else
                        ...item.payerIds.map((personId) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('  - ${_getPersonName(personId)}'),
                                Text(
                                    '+${amountPerPayer.toStringAsFixed(2)} บาท'),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              );
            }).toList(), // ใช้ ... (spread operator) เพื่อรวม List<Widget> เข้าด้วยกัน
          const SizedBox(height: 24),

          // --- ส่วนสรุปยอดที่แต่ละคนต้องจ่าย (จากที่คำนวณไว้) ---
          Text(
            'สรุปยอดที่แต่ละคนต้องจ่ายรวม',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          if (individualShares.isEmpty)
            const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text("ยังไม่ได้คำนวณยอด",
                  style: TextStyle(color: Colors.grey)),
            ))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: people.length,
              itemBuilder: (context, index) {
                final person = people[index];
                final share = individualShares[person.id] ?? 0.0;
                // ไม่แสดงคนที่ไม่ต้องจ่ายอะไรเลย (ยอดเป็น 0)
                if (share <= 0) return const SizedBox.shrink();

                return ListTile(
                  leading: CircleAvatar(
                      child: Text(person.name.isNotEmpty
                          ? person.name[0].toUpperCase()
                          : '?')),
                  title: Text(person.name),
                  trailing: Text(
                    '${share.toStringAsFixed(2)} บาท',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red // ทุกคนมียอดจ่ายเป็นบวก
                        ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
