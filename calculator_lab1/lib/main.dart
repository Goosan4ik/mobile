import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String display = '';
  bool wasEqualPressed = false;

  final nums = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  final ops = ['/', '*', '-', '+', '^'];

  final Color opColor = Color.fromARGB(255, 255, 128, 0);
  final Color numColor = Color.fromARGB(255, 128, 128, 128);
  final Color textColor = Colors.white;

  void buttonPressed(String text) {
    setState(() {
      if (text == "C") {
        display = '';
        wasEqualPressed = false;
      } else if (text == "Del") {
        if (display.isEmpty) return;
        display = display.substring(0, display.length - 1);
      } else if (text == "=") {
        calculate();
      } else {
        if (display.length >= 30 && text != 'Del') return;

        if (wasEqualPressed && nums.contains(text)) {
          display = text;
          wasEqualPressed = false;
          return;
        }

        if (wasEqualPressed && ops.contains(text)) {
          wasEqualPressed = false;
        }

        if (nums.contains(text)) {
          handleNumber(text);
        } else if (ops.contains(text)) {
          handleOperator(text);
        } else if (text == '.') {
          handleDot();
        }
      }
    });
  }

  void handleNumber(String n) {
    if (display == '0' && n == '0') return;

    if (display == '0' && n != '0') {
      display = n;
    } else if (display == 'Error' || wasEqualPressed) {
      display = n;
      wasEqualPressed = false;
    } else {
      display += n;
    }
  }

  void handleOperator(String op) {
    if (display.isEmpty || display == 'Error') return;

    var last = display[display.length - 1];

    if (nums.contains(last) || last == '.') {
      display += op;
    } else if (ops.contains(last)) {
      if (display.length > 1) {
        display = display.substring(0, display.length - 1) + op;
      } else {
        display = op;
      }
    }

    wasEqualPressed = false;
  }

  void handleDot() {
    if (display.isEmpty) {
      display = '0.';
      return;
    }

    if (display == 'Error') {
      display = '0.';
      return;
    }

    var last = display[display.length - 1];

    if (ops.contains(last)) {
      display += '0.';
      return;
    }

    var parts = display.split(RegExp(r'[+\-*/^]'));
    var current = parts.last;

    if (!current.contains('.')) {
      display += '.';
    }
  }

  void calculate() {
    if (display.isEmpty || display == 'Error') return;

    if (display.contains('/0')) {
      var idx = display.indexOf('/0');
      if (idx + 2 >= display.length || !nums.contains(display[idx + 2])) {
        display = 'Error';
        wasEqualPressed = false;
        return;
      }
    }

    try {
      var p = Parser();
      var exp = p.parse(display);
      var cm = ContextModel();
      var res = exp.evaluate(EvaluationType.REAL, cm);

      if (res.isInfinite || res.isNaN) {
        display = 'Error';
        wasEqualPressed = false;
        return;
      }

      var resultStr = res.toString();

      if (resultStr.contains('.')) {
        resultStr = resultStr.replaceAll(RegExp(r'0+$'), '');
        if (resultStr.endsWith('.')) {
          resultStr = resultStr.substring(0, resultStr.length - 1);
        }

        if (resultStr.split('.')[1].length > 6) {
          resultStr = res.toStringAsFixed(6);
        }
      }

      if (resultStr.length > 12) {
        resultStr = double.parse(resultStr).toStringAsExponential(6);
      }

      display = resultStr;
      wasEqualPressed = true;

    } catch (e) {
      display = 'Error';
      wasEqualPressed = false;
    }
  }

  double getFontSize() {
    if (display.isEmpty) return 30.0;

    var len = display.length;
    if (len <= 10) return 30.0;
    if (len <= 15) return 25.0;
    if (len <= 20) return 20.0;
    return 16.0;
  }

  Widget makeButton(String txt, Color bg, {bool wide = false}) {
    return Expanded(
      flex: wide ? 2 : 1,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(20),
          ),
          onPressed: () {
            buttonPressed(txt);
          },
          child: Text(
            txt,
            style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w500
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            'Калькулятор',
            style: TextStyle(
              color: Color.fromARGB(255, 225, 225, 225),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: opColor,
                  width: 3.0,
                ),
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.centerRight,
              constraints: BoxConstraints(
                minHeight: 80,
                maxHeight: 120,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  display.isEmpty ? '0' : display,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: getFontSize(),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
            ),

            Column(
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    makeButton('C', opColor),
                    makeButton('/', opColor),
                    makeButton('*', opColor),
                    makeButton('Del', opColor),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    makeButton('7', numColor),
                    makeButton('8', numColor),
                    makeButton('9', numColor),
                    makeButton('-', opColor),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    makeButton('4', numColor),
                    makeButton('5', numColor),
                    makeButton('6', numColor),
                    makeButton('+', opColor),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    makeButton('1', numColor),
                    makeButton('2', numColor),
                    makeButton('3', numColor),
                    makeButton('^', opColor),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    makeButton('0', numColor, wide: true),
                    makeButton('.', numColor),
                    makeButton('=', opColor),
                  ],
                ),
              ],
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}