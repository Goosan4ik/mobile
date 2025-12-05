import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Calculator();
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  // Данные по категориям конвертера
  final categoryData = {
    'Вес': {
      'route': '/weight',
      'types': ['г', 'кг', 'т'],
      'coef': [1, 0.001, 0.000001],
      'color': Color(0xFFE91E63),
    },
    'Объем': {
      'route': '/volume',
      'types': ['л', 'мл', 'м³'],
      'coef': [1, 1000, 0.001],
      'color': Color(0xFF2196F3),
    },
    'Расстояние': {
      'route': '/distance',
      'types': ['м', 'км', 'см'],
      'coef': [1, 0.001, 100],
      'color': Color(0xFF4CAF50),
    },
    'Валюта': {
      'route': '/currency',
      'types': ['USD', 'EUR', 'RUB'],
      'coef': [1, 1.1, 90],
      'color': Color(0xFFFF9800),
    },
    'Площадь': {
      'route': '/square',
      'types': ['м²', 'км²', 'см²'],
      'coef': [1, 0.000001, 10000],
      'color': Color(0xFF9C27B0),
    },
  };

  Widget _buildCategoryButton(String title, Map<String, dynamic> data) {
    final color = data['color'] as Color;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.pushNamed(
                context,
                data['route'],
                arguments: {'list': data},
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.8),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'CONVERTER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Divider(
              color: Colors.white.withOpacity(0.3),
              thickness: 1,
              height: 20,
            ),
            const SizedBox(height: 25),

            Expanded(
              child: ListView(
                children: categoryData.entries.map((entry) {
                  final title = entry.key;
                  final data = entry.value;

                  return Column(
                    children: [
                      _buildCategoryButton(title, data),
                      if (title != 'Площадь') const SizedBox(height: 25),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}