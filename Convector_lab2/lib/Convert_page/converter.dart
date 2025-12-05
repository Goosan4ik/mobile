import 'package:flutter/material.dart';

class Converter extends StatefulWidget {
  const Converter({super.key});

  @override
  State<Converter> createState() => _ConverterState();
}

class _ConverterState extends State<Converter> {
  Map<String, dynamic>? categoryData;
  List<String> units = [];
  List<double> coefficients = [];
  Color mainColor = Colors.blue;

  String selectedFromUnit = '';
  String selectedToUnit = '';

  double inputNumber = 0;
  double resultNumber = 0;

  final TextEditingController inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  void _loadCategoryData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (routeArgs != null && routeArgs.containsKey('list')) {
        setState(() {
          categoryData = routeArgs['list'] as Map<String, dynamic>;
          units = List<String>.from(categoryData!['types'] as List);

          final coefList = categoryData!['coef'];
          if (coefList is List) {
            coefficients = coefList.map<double>((item) => item.toDouble()).toList();
          } else {
            coefficients = [];
          }

          mainColor = categoryData!['color'] as Color;

          if (units.length >= 2) {
            selectedFromUnit = units[0];
            selectedToUnit = units[1];
          }
        });
      }
    });
  }

  void _performConversion() {
    if (inputController.text.isEmpty || units.isEmpty || coefficients.isEmpty) {
      setState(() {
        resultNumber = 0;
      });
      return;
    }

    try {
      final number = double.tryParse(inputController.text) ?? 0;
      setState(() {
        inputNumber = number;
      });

      final fromIndex = units.indexOf(selectedFromUnit);
      final toIndex = units.indexOf(selectedToUnit);

      if (fromIndex == -1 || toIndex == -1 || fromIndex >= coefficients.length || toIndex >= coefficients.length) {
        _displayMessage('Ошибка в выборе единиц измерения');
        return;
      }

      final baseValue = inputNumber / coefficients[fromIndex];
      final convertedValue = baseValue * coefficients[toIndex];

      setState(() {
        resultNumber = convertedValue;
      });
    } catch (error) {
      _displayMessage('Не удалось выполнить конвертацию');
    }
  }

  void _switchUnits() {
    if (units.length < 2) return;

    setState(() {
      final temp = selectedFromUnit;
      selectedFromUnit = selectedToUnit;
      selectedToUnit = temp;
      _performConversion();
    });
  }

  void _displayMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _pressNumber(String number) {
    setState(() {
      if (inputController.text == '0' || inputController.text == '0.0') {
        inputController.text = number;
      } else {
        inputController.text += number;
      }
    });
  }

  void _addPoint() {
    setState(() {
      if (!inputController.text.contains('.')) {
        if (inputController.text.isEmpty) {
          inputController.text = '0.';
        } else {
          inputController.text += '.';
        }
      }
    });
  }

  void _resetInput() {
    setState(() {
      inputController.clear();
      resultNumber = 0;
    });
  }

  void _removeLastCharacter() {
    setState(() {
      if (inputController.text.isNotEmpty) {
        inputController.text = inputController.text.substring(0, inputController.text.length - 1);
        if (inputController.text.isEmpty) {
          resultNumber = 0;
        }
      }
    });
  }

  Widget _createNumberButton(String number) {
    return Expanded(
      child: Container(
        height: 70,
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[850],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          onPressed: () => _pressNumber(number),
          child: Text(
            number,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }

  Widget _createFunctionButton(String text, Color buttonColor, VoidCallback onTap, {IconData? icon}) {
    return Expanded(
      child: Container(
        height: 70,
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          onPressed: onTap,
          child: icon != null
              ? Icon(icon, size: 22)
              : Text(
            text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (categoryData == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'КОНВЕРТЕР',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          categoryData!['name'] as String? ?? 'КОНВЕРТЕР',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [

                  DropdownButtonFormField<String>(
                    value: selectedFromUnit.isNotEmpty ? selectedFromUnit : null,
                    items: units.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (newUnit) {
                      if (newUnit != null) {
                        setState(() {
                          selectedFromUnit = newUnit;
                        });
                      }
                    },
                    dropdownColor: Colors.grey[900],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Из',
                      labelStyle: TextStyle(color: mainColor),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: mainColor),
                  ),

                  const SizedBox(height: 12),


                  TextField(
                    controller: inputController,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      labelText: 'Введите число',
                      labelStyle: TextStyle(color: mainColor),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    readOnly: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.swap_horiz, color: mainColor, size: 24),
                  ),
                  onPressed: _switchUnits,
                ),


                ElevatedButton(
                  onPressed: _performConversion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calculate, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Рассчитать',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),


            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [

                  DropdownButtonFormField<String>(
                    value: selectedToUnit.isNotEmpty ? selectedToUnit : null,
                    items: units.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (newUnit) {
                      if (newUnit != null) {
                        setState(() {
                          selectedToUnit = newUnit;
                        });
                      }
                    },
                    dropdownColor: Colors.grey[900],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'В',
                      labelStyle: TextStyle(color: mainColor),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: mainColor),
                  ),

                  const SizedBox(height: 12),


                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatResult(resultNumber),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Icon(Icons.content_copy, color: mainColor, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),


            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Row(children: ['1', '2', '3'].map(_createNumberButton).toList()),
                  ),

                  Expanded(
                    child: Row(children: ['4', '5', '6'].map(_createNumberButton).toList()),
                  ),

                  Expanded(
                    child: Row(children: ['7', '8', '9'].map(_createNumberButton).toList()),
                  ),

                  Expanded(
                    child: Row(
                      children: [
                        _createFunctionButton('.', Colors.grey[800]!, _addPoint),
                        _createNumberButton('0'),
                        _createFunctionButton('C', Colors.grey[800]!, _resetInput),
                        _createFunctionButton('', Colors.red[900]!, _removeLastCharacter,
                            icon: Icons.backspace),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatResult(double value) {
    return value.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }
}