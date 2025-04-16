import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bill_splitting_app/providers/bill_provider.dart';
import 'package:bill_splitting_app/widgets/items_tab.dart';
import 'package:bill_splitting_app/widgets/people_tab.dart';
import 'package:bill_splitting_app/widgets/add_item_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BillProvider _billProvider = BillProvider();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _billProvider,
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  ItemsTab(),
                  PeopleTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        return Container(
          color: Colors.grey[700],
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'จำนวนคน',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '${billProvider.numberOfPeople}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ราคารวม',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '${billProvider.totalAmount.toInt()}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Text(
                      'ADD PROMPPAY',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          // Add PromptPay functionality
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: [
        Tab(
          icon: const Icon(Icons.list),
          text: 'รายการ',
        ),
        Tab(
          icon: const Icon(Icons.people),
          text: 'คนจ่าย',
        ),
      ],
    );
  }
}
