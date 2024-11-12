import 'package:flutter/material.dart';

const _initialItems = ['вода', 'огонь', 'воздух', 'земля'];

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Alchemy',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  static const _paddings = 12.0;

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: _paddings,
          crossAxisSpacing: _paddings,
        ),
        itemCount: _initialItems.length,
        itemBuilder: (context, index) {
          return Container(height: 100, width: 100, color: Colors.blue);
        },
      ),
    );
  }
}
