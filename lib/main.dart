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
  static const _itemsSize = 100.0;
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
            return DragDropItem(
              data: item,
              size: _itemsSize,
              color: _color,
              child: Center(child: Text(item)),
              onTargetReached: (target) {
                print('from: $item, to: $target');
              },
            );
          },
        ),
      ),
    );
  }
}

class DragDropItem<T extends Object> extends StatelessWidget {
  final T data;
  final double size;
  final Color color;
  final ValueChanged<T>? onTargetReached;
  final Widget? child;

  const DragDropItem({
    super.key,
    required this.data,
    this.size = 50,
    this.color = Colors.grey,
    this.onTargetReached,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final itemContainer = Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: child,
    );
    return Center(
      child: Draggable<T>(
        data: data,
        childWhenDragging: const SizedBox.shrink(),
        feedback: Material(color: Colors.transparent, child: itemContainer),
        child: DragTarget<T>(
          builder: (context, accepted, rejected) => itemContainer,
          onAcceptWithDetails: (details) => onTargetReached?.call(details.data),
        ),
      ),
    );
  }
}
