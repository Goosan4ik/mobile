import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime current = DateTime.now();
  DateTime selected = DateTime.now();

  final months = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
  ];

  final week = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  List<DateTime> getDays() {
    final first = DateTime(current.year, current.month, 1);
    final last = DateTime(current.year, current.month + 1, 0);

    final start = first.subtract(Duration(days: first.weekday - 1));
    final end = last.add(Duration(days: 7 - last.weekday));

    final days = <DateTime>[];
    var day = start;

    while (!day.isAfter(end)) {
      days.add(day);
      day = day.add(const Duration(days: 1));
    }

    return days;
  }

  void monthBack() {
    setState(() {
      current = DateTime(current.year, current.month - 1);
    });
  }

  void monthNext() {
    setState(() {
      current = DateTime(current.year, current.month + 1);
    });
  }

  void goNow() {
    setState(() {
      current = DateTime.now();
      selected = DateTime.now();
    });
  }

  void chooseDate(DateTime date) {
    setState(() {
      selected = date;
    });
  }

  bool isNow(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool isSelected(DateTime date) {
    return date.year == selected.year && date.month == selected.month && date.day == selected.day;
  }

  bool sameMonth(DateTime date) {
    return date.month == current.month;
  }

  void _showYearPickerDialog() {
    final int currentYear = current.year;
    final List<int> years = List.generate(21, (index) => currentYear - 10 + index);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Выбор года'),
              TextButton(
                onPressed: () {
                  setState(() {
                    current = DateTime.now();
                  });
                  Navigator.pop(context);
                },
                child: const Text('Текущий'),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.0,
              ),
              itemCount: years.length,
              itemBuilder: (context, index) {
                final year = years[index];
                final isCurrentYear = year == DateTime.now().year;
                final isSelectedYear = year == current.year;

                return InkWell(
                  onTap: () {
                    setState(() {
                      current = DateTime(year, current.month);
                    });
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelectedYear
                          ? Colors.orange
                          : isCurrentYear
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: isCurrentYear
                            ? Colors.black
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        year.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isCurrentYear ? FontWeight.bold : FontWeight.normal,
                          color: isSelectedYear ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = getDays();
    final needTodayBtn = current.year != DateTime.now().year || current.month != DateTime.now().month;

    return Scaffold(
      appBar: AppBar(title: const Text('Календарь')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: monthBack,
                      icon: const Icon(Icons.arrow_left),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${months[current.month - 1]} ${current.year}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          GestureDetector(
                            onTap: _showYearPickerDialog,
                            child: Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Сменить год',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: monthNext,
                      icon: const Icon(Icons.arrow_right),
                    ),
                  ],
                ),
                if (needTodayBtn)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ElevatedButton(
                      onPressed: goNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Текущий месяц'),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: week.map((day) {
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.2,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final date = days[index];
                final now = isNow(date);
                final chosen = isSelected(date);
                final thisMonth = sameMonth(date);

                return GestureDetector(
                  onTap: () => chooseDate(date),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: chosen ? Colors.orange : null,
                      shape: BoxShape.circle,
                      border: now ? Border.all(color: Colors.black, width: 2) : null,
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: chosen
                              ? Colors.white
                              : thisMonth
                              ? Colors.black
                              : Colors.grey,
                          fontWeight: now ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Выбранная дата: ${selected.day}.${selected.month}.${selected.year}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}