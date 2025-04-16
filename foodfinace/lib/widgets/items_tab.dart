import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bill_splitting_app/providers/bill_provider.dart';
import 'package:bill_splitting_app/widgets/add_item_dialog.dart';

class ItemsTab extends StatelessWidget {
  const ItemsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        return Column(
          children: [
            Expanded(
              child: billProvider.items.isEmpty
                  ? const Center(child: Text('ไม่มีรายการอาหาร'))
                  : ListView.builder(
                      itemCount: billProvider.items.length,
                      itemBuilder: (context, index) {
                        final item = billProvider.items[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text('${item.sharedBy.length} คน หารคนละ ${(item.price / item.sharedBy.length).toStringAsFixed(2)} บาท'),
                          trailing: Text('${item.price.toStringAsFixed(2)} บาท'),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'ระบุชื่อ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AddItemDialog(),
                      );
                    },
                    child: const Text('เพิ่ม'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'สำรายชื่อคนจ่ายทั้งหมด',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text('แชร์ลิง'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        billProvider.shareLink ?? 'https://phpstack-988892-3470693.cloudwaysapps.com',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      billProvider.generateShareLink();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('คัดลอกลิงค์แล้ว')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
