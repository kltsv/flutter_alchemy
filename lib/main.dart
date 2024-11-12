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
  static const _color = Colors.blue;

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(_paddings),
        child: GridView.builder(
          reverse: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: _paddings,
            crossAxisSpacing: _paddings,
          ),
          itemCount: _initialItems.length,
          itemBuilder: (context, index) {
            final item = _initialItems[index];
            return Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _color,
              ),
              child: Center(child: Text(item)),
            );
          },
        ),
      ),
    );
  }
}
