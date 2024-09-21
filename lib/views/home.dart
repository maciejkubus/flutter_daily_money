import 'package:flutter/material.dart';
import 'package:flutter_daily_money/widgets/day.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  DateTime? _paydayFrom;
  DateTime? _payday;
  int _daysLeft = 0;
  int _dailyMoney = 0;

  @override
  void initState() {
    super.initState();
    _loadData(); // Load payday when the view is created
  }

  // Reload data when returning to HomeView
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  // Load payday from shared preferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    String paydayFrom = prefs.getString('payday-from') ?? '2024-1-1';
    setState(() {
      _paydayFrom = DateTime.tryParse(paydayFrom);
    });

    String? savedDate = prefs.getString('payday');
    if (savedDate != null) {
      setState(() {
        _payday = DateTime.tryParse(savedDate);
        _calculateDaysLeft();
      });
    } else {
      setState(() {
        _payday = null;
        _daysLeft = 0;
      });
    }

    int? money = int.parse(prefs.getString('money') ?? '0');
    setState(() {
      _dailyMoney = money ~/ (_daysLeft > 0 ? _daysLeft : 1);
    });
  }

  // Calculate days left until payday
  void _calculateDaysLeft() {
    if (_payday != null && _paydayFrom != null) {
      setState(() {
        _daysLeft = _payday!.difference(_paydayFrom!).inDays;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _payday != null ? '$_daysLeft days left' : 'Payday not set',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_dailyMoney zł per day',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          _dailyMoney > 0
              ? Day(dailyMoney: _dailyMoney)
              : const SizedBox(
                  height: 8,
                )
        ],
      ),
    );
  }
}
