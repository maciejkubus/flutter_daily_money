import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Day extends StatefulWidget {
  final int dailyMoney;

  const Day({Key? key, required this.dailyMoney}) : super(key: key);

  @override
  _DayState createState() => _DayState();
}

class _DayState extends State<Day> {
  final TextEditingController _transactionController = TextEditingController();
  int _allowance = 0;
  List<int> _transactions = [];
  late String _today;

  @override
  void initState() {
    super.initState();
    _today = _getToday(); // Get current date string
    _loadData(); // Load allowance and transactions
  }

  // Get today's date as a string (e.g., "2024-09-19")
  String _getToday() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  // Load saved data (allowance and transactions for today) from SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String allTransactionsString =
        prefs.getString('transactions') ?? "{}";
    Map<String, dynamic> allTransactions = jsonDecode(allTransactionsString);

    if (allTransactions.containsKey(_today)) {
      List<dynamic> transactionList = allTransactions[_today];
      setState(() {
        _transactions = transactionList.map((e) => e as int).toList();
        _allowance = widget.dailyMoney -
            _transactions.fold(0, (sum, item) => sum + item);
      });
    } else {
      setState(() {
        _allowance = widget.dailyMoney;
      });
    }
  }

  // Save transactions for the current day to SharedPreferences
  Future<void> _saveTransaction(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final String? allTransactionsString = prefs.getString('transactions');
    Map<String, dynamic> allTransactions = {};

    if (allTransactionsString != null) {
      allTransactions = jsonDecode(allTransactionsString);
    }

    // Add today's transaction
    if (!allTransactions.containsKey(_today)) {
      allTransactions[_today] = [];
    }

    // Update the transactions for today
    allTransactions[_today].add(amount);

    // Update the allowance and transactions list
    setState(() {
      _transactions.add(amount);
      _allowance -= amount;
    });

    // Save updated transactions back to SharedPreferences
    await prefs.setString('transactions', jsonEncode(allTransactions));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction added!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Allowance: $_allowance',
            style: TextStyle(
              fontSize: 24,
              color: _allowance >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _transactionController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Transaction amount',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final int transaction =
                  int.tryParse(_transactionController.text) ?? 0;
              if (transaction > 0 && transaction <= _allowance) {
                _saveTransaction(transaction);
                _transactionController.clear();
              }
            },
            child: const Text(
              'Add Transaction',
              style: TextStyle(fontSize: 20),
            ),
          ),
          // const SizedBox(height: 16),
          // Column(children: [
          //   ListView.builder(
          //     shrinkWrap: true,
          //     itemCount: _transactions.length,
          //     itemBuilder: (context, index) {
          //       return ListTile(
          //         title: Text('Transaction: ${_transactions[index]} zł'),
          //       );
          //     },
          //   ),
          // ]),
        ],
      ),
    );
  }
}
