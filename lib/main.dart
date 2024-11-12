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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _paddings = 12.0;
  static const _itemsSize = 100.0;
  static final _color = Colors.blue.withAlpha(50);

  final List<String> _items = [
    ..._initialItems,
  ];

  final _combinations = <String, String>{};

  @override
  Widget build(BuildContext context) {
    int crossAxisCount =
        (MediaQuery.of(context).size.width / _itemsSize).floor();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(_paddings),
        child: GridView.builder(
          reverse: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: _paddings,
            crossAxisSpacing: _paddings,
          ),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return DragDropItem(
              data: item,
              size: _itemsSize,
              color: _color,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(_paddings / 2),
                  child: FittedBox(
                    child: Text(
                      item,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              onTargetReached: (origin) => _combine(origin, item),
            );
          },
        ),
      ),
    );
  }

  void _combine(String origin, String target) {
    print('from: $origin, to: $target');

    // TODO: calculate new item

    // Save the result of the current pair to cache
    final combination = ([origin, target]..sort()).join('+');
    _combinations[combination] = combination; // TODO: cache new item

    setState(() => _items.add(combination));
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
    final pulseContainer =
        PulseAnimation(size: size, color: color, child: child);
    return Center(
      child: Draggable<T>(
        data: data,
        childWhenDragging: const SizedBox.shrink(),
        feedback: Material(
          color: Colors.transparent,
          child: pulseContainer,
        ),
        child: DragTarget<T>(
          builder: (context, accepted, rejected) =>
              accepted.isEmpty ? itemContainer : pulseContainer,
          onAcceptWithDetails: (details) => onTargetReached?.call(details.data),
        ),
      ),
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final double? size;
  final Color? color;
  final Widget? child;

  const PulseAnimation({
    super.key,
    this.size,
    this.color,
    this.child,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5 * 150),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
