import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _formKey = GlobalKey<FormState>();
  final _moneyController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _moneyController.dispose();
    super.dispose();
  }

  // Load settings from shared preferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _moneyController.text = prefs.getString('money') ?? '1000';
      String? savedDate = prefs.getString('payday');
      if (savedDate != null) {
        _selectedDate = DateTime.tryParse(savedDate);
      } else {
        _selectedDate = DateTime.now();
      }
    });
  }

  // Save settings to shared preferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('money', _moneyController.text);
    if (_selectedDate != null) {
      await prefs.setString('payday', _selectedDate!.toIso8601String());
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings saved!'),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Money Input
            TextFormField(
              controller: _moneyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Money',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            // Date Input (Payday)
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No date selected'
                        : 'Selected date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    'Select Payday',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: _saveForm,
                child: Text(
                  'Save',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
