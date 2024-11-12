import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const apiKey = String.fromEnvironment('GEMINI_API_KEY');
const separator = ',';

const _initialItems = ['вода', 'огонь', 'воздух', 'земля'];

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Alchemy',
      home: apiKey.isNotEmpty
          ? const HomePage()
          : const Scaffold(
              body: Center(child: Text('API key was not provided')),
            ),
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
  static const _loadingColor = Colors.lightBlueAccent;

  final List<String?> _items = [
    ..._initialItems,
  ];

  final _combinations = <String, String>{};

  bool get _isLoading => _items.contains(null);

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
            if (item != null) {
              return DragDropItem(
                data: item,
                size: _itemsSize,
                color: _color,
                locked: _isLoading,
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
            } else {
              return const Center(
                child: PulseAnimation(
                  size: _itemsSize / 2,
                  color: _loadingColor,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _combine(String origin, String target) async {
    print('from: $origin, to: $target');

    // Start loading animation by adding special item to the list
    setState(() => _items.add(null));
    // TODO: calculate new item
    await Future.delayed(const Duration(seconds: 1));

    // Save the result of the current pair to cache
    final combination = ([origin, target]..sort()).join('+');
    _combinations[combination] = combination; // TODO: cache new item

    setState(() {
      // Remove loading item from the list before adding an actual one
      _items.removeLast();
      _items.add(combination);
    });
  }
}

class DragDropItem<T extends Object> extends StatelessWidget {
  final T data;
  final double size;
  final Color color;
  final bool locked;
  final ValueChanged<T>? onTargetReached;
  final Widget? child;

  const DragDropItem({
    super.key,
    required this.data,
    this.size = 50,
    this.color = Colors.grey,
    this.locked = false,
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
      child: IgnorePointer(
        ignoring: locked,
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
            onAcceptWithDetails: (details) =>
                onTargetReached?.call(details.data),
          ),
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

final _ai = GenerativeModel(
  model: 'gemini-1.5-flash-latest',
  apiKey: apiKey,
);

String _prompt(String origin, String target, List<String> exclude) =>
    'We are playing the Fun Alchemy Game. There two items, '
    'and as a result of combining these two items appears some new item, '
    'that can be combined in the next steps with other items. '
    'The new item must be in some way more complex then two original items. '
    'The item MUST be different from the original two items. '
    'You MUST answer in Russian. '
    'You MUST answer only with a single noun. '
    'Do not repeat original items. '
    'Do not answer with words: {${exclude.join(',')}}. '
    'Items to combine: $origin + $target. '
    'Your answer is: ';
