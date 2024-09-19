import 'dart:convert'; // For JSON encoding/decoding
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({Key? key}) : super(key: key);

  @override
  _HistoryViewState createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  DateTime _selectedDate = DateTime.now();
  late Future<List<int>> _transactionsFuture;
  late String _formattedDate;

  @override
  void initState() {
    super.initState();
    _formattedDate = _formatDate(_selectedDate);
    _transactionsFuture = _loadTransactions();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  Future<List<int>> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String allTransactionsString =
        prefs.getString('transactions') ?? "{}";
    Map<String, dynamic> allTransactions = jsonDecode(allTransactionsString);
    log(allTransactionsString);

    return (allTransactions[_formattedDate] ?? [])
        .map<int>((e) => e as int)
        .toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _formattedDate = _formatDate(_selectedDate);
        _transactionsFuture = _loadTransactions(); // Refresh transactions
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () => _selectDate(context),
            child: Text(
              'Select Date: ${_formatDate(_selectedDate)}',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<int>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No transactions for the selected date.'));
                } else {
                  final transactions = snapshot.data!;
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Transaction: ${transactions[index]} zł'),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
