import 'package:flutter/material.dart';
import 'package:flutter_joystick/chat_interface.dart';
import 'package:flutter_joystick/joystick_page.dart';
import 'package:flutter_joystick/piechart_page.dart';
import 'package:flutter_joystick/wheel_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  void callback(x, y) {
    print('callback x => $x and y $y');
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = JoyStick(radius: 100.0, stickRadius: 40.0, callback: callback);
        break;
      case 1:
        page = PieChart();
        break;
      case 2:
        page = WheelSelect();
        break;
      case 3:
        page = ChatInterface();
        break;
      default:
        page = JoyStick(radius: 100.0, stickRadius: 40.0, callback: callback);
    }

    return Scaffold(
      body: Container(color: Theme.of(context).colorScheme.primaryContainer, child: page),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: 'Joystick'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Pie Chart'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Wheel'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: (int index) {
          // Handle navigation
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
