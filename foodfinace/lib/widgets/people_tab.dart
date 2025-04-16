import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bill_splitting_app/providers/bill_provider.dart';

class PeopleTab extends StatefulWidget {
  const PeopleTab({super.key});

  @override
  State<PeopleTab> createState() => _PeopleTabState();
}

class _PeopleTabState extends State<PeopleTab> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        return Column(
          children: [
            Expanded(
              child: billProvider.people.isEmpty
                  ? const Center(child: Text('ไม่มีคนจ่าย'))
                  : ListView.builder(
                      itemCount: billProvider.people.length,
                      itemBuilder: (context, index) {
                        final person = billProvider.people[index];
                        return ListTile(
                          title: Text(person.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${person.amountPaid.toStringAsFixed(2)} บาท'),
                              IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () {
                                  // Show options for this person
                                },
                              ),
                            ],
                          ),
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
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อคน',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.trim().isNotEmpty) {
                        billProvider.addPerson(_nameController.text);
                        _nameController.clear();
                      }
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
