// ignore_for_file: avoid_print
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const apiKey = String.fromEnvironment('GEMINI_API_KEY');
const separator = ',';

const _initialItems = [
  Item(value: 'вода', level: 1, emoji: '💧'),
  Item(value: 'огонь', level: 1, emoji: '🔥'),
  Item(value: 'воздух', level: 1, emoji: '💨'),
  Item(value: 'земля', level: 1, emoji: '🪨'),
];

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final TextEditingController _textController;
  var _apiKey = apiKey.isNotEmpty ? apiKey : null;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final key = _apiKey;
    return MaterialApp(
      title: 'Flutter Alchemy',
      home: key != null
          ? HomePage(apiKey: key)
          : Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('Enter your Google AIStudio API key.'),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: FittedBox(
                        child: SelectableText(
                          'Read instruction at: https://github.com/kltsv/flutter_alchemy',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextField(
                        controller: _textController,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_textController.text.isNotEmpty) {
                          setState(() => _apiKey = _textController.text);
                        }
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String apiKey;

  const HomePage({
    super.key,
    required this.apiKey,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _paddings = 12.0;
  static const _itemsSize = 100.0;
  static final _initialColor = Colors.blue.withAlpha(50);
  static const _loadingColor = Colors.lightBlueAccent;

  late final _ai = _createAI(widget.apiKey);

  final List<Item?> _items = [
    null,
  ];

  final _combinations = <String, Item>{};

  final _colors = <int, Color>{};

  bool get _isLoading => _items.contains(null);

  @override
  void initState() {
    super.initState();
    _colors[1] = _initialColor;
    _createInitialItems();
  }

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
                color: _colors[item.level]!,
                locked: _isLoading,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(_paddings / 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (item.emoji != null)
                          Text(
                            item.emoji!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        FittedBox(
                          child: Text(
                            item.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
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

  Future<void> _combine(Item origin, Item target) async {
    print('from: ${origin.value}, to: ${target.value}');

    // Start loading animation by adding special item to the list
    setState(() => _items.add(null));

    // Check if cached value for this pair exists
    final combination = ([origin.value, target.value]..sort()).join('+');
    final existingCombination = _combinations[combination];

    late final String value;
    late final int level;
    late final String? emoji;

    if (existingCombination == null) {
      // No previous generation for the pair
      print('Generating...');
      final exclude = [
        ..._initialItems,
        ..._combinations.values,
      ];
      try {
        final prompt =
            _prompt(origin.value, target.value, exclude.map((e) => e.value));
        final content = [Content.text(prompt)];
        final response = await _ai.generateContent(content);
        final rawValue = response.text!.trim().toLowerCase();
        value = rawValue.split(separator).elementAt(0);
        level = max(origin.level, target.level) + 1;
        emoji = rawValue.split(separator).elementAt(1);
        print('Answer: $value $emoji ($level)');
      } catch (e) {
        setState(() {
          // Remove loading item when exception appears
          _items.removeLast();
        });
        print('Exception: $e');
        return;
      }
    } else {
      // The previous generation exists for the pair, use from cache
      value = existingCombination.value;
      level = existingCombination.level;
      emoji = existingCombination.emoji;
    }

    if (!_colors.containsKey(level)) {
      final prevLevelColor = _colors[level - 1]!;
      _colors[level] = Color.fromARGB(
        min(prevLevelColor.alpha + 10, 255), // Deeper color with each level
        prevLevelColor.red,
        prevLevelColor.green,
        prevLevelColor.blue,
      );
    }
    final newItem = Item(value: value, level: level, emoji: emoji);

    // Save the result of the current pair to cache
    _combinations[combination] = newItem;

    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      // Remove loading item from the list before adding an actual one
      _items.removeLast();
      _items.add(newItem);
    });
  }

  Future<void> _createInitialItems() async {
    print('Generating initial items...');
    try {
      final prompt = _initialItemsPrompt();
      final content = [Content.text(prompt)];
      final response = await _ai.generateContent(content);
      final rawValue = response.text!.trim().toLowerCase();
      final initialWords = rawValue.split(separator);
      print('Initial items are: [${initialWords.join(',')}]');
      final initialItems = initialWords.map((i) => Item(value: i, level: 1));
      setState(() {
        _items.removeLast();
        _items.addAll(initialItems);
      });
    } catch (e) {
      setState(() {
        _items.removeLast();
        _items.addAll(_initialItems);
      });
      print('Exception: $e');
    }
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

GenerativeModel _createAI(String apiKey) => GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

String _prompt(String origin, String target, Iterable<String> exclude) =>
    'We are playing the Fun Alchemy Game. There are two items, '
    'and as a result of combining these two items, some new item appears and '
    'this new item can be combined in the next steps with other items. '
    'The new item must be in some way more complex then two original items. '
    'The item MUST be different from the original two items. '
    'You MUST answer in Russian. '
    'You MUST answer only with a single noun. '
    'Do not repeat original items. '
    'After the word add the most relevant single emoji. '
    'Separate a word and emoji with a `$separator` sign. '
    'Do not answer with words: {${exclude.join(',')}}. '
    'Items to combine: $origin + $target. '
    'Your answer is: ';

String _initialItemsPrompt() =>
    'Come up with FOUR random nouns, separated with a $separator sign. '
    'These nouns must represent some actual item or material or physical thing. '
    'You MUST answer only with FOUR NOUN WORDS, NOTHING ELSE, NO DOT AT THE END. '
    'You MUST answer in Russian. '
    'Your answer is: ';

class Item {
  final String value;
  final int level;
  final String? emoji;

  const Item({
    required this.value,
    required this.level,
    this.emoji,
  });
}
