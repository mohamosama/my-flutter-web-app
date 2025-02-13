import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'لعبة الحروف المميزة',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Cairo',
      ),
      home: const InputScreen(),
    );
  }
}

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _controller = TextEditingController();

  void _navigateToCardsScreen() {
    final word = _controller.text.trim().replaceAll(' ', '');
    if (word.isNotEmpty) {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => CardsScreen(word: word),
          transitionsBuilder: (_, a, __, c) => FadeTransition(
            opacity: a,
            child: ScaleTransition(scale: a, child: c),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)])),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'أدخل كلمتك السرية يا محترم...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 32),
                        onPressed: _navigateToCardsScreen,
                      ),
                    ),
                    onSubmitted: (_) => _navigateToCardsScreen,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome, size: 28),
                  label: const Text('يلا بينا ',
                      style: TextStyle(fontSize: 22)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.white,
                    elevation: 10,
                    shadowColor: Colors.amber[300],
                  ),
                  onPressed: _navigateToCardsScreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardsScreen extends StatefulWidget {
  final String word;
  const CardsScreen({super.key, required this.word});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen>
    with SingleTickerProviderStateMixin {
  late List<bool> revealedLetters;
  final TextEditingController _letterController = TextEditingController();
  int wrongAttempts = 0;
  String errorMessage = '';
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    revealedLetters = List.filled(widget.word.length, false);
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  void _checkLetter() async {
    final letter = _letterController.text.trim();
    if (letter.isEmpty || letter == ' ') return;

    HapticFeedback.mediumImpact();
    bool found = false;
    setState(() {
      for (int i = 0; i < widget.word.length; i++) {
        if (widget.word[i].toLowerCase() == letter.toLowerCase()) {
          revealedLetters[i] = true;
          found = true;
        }
      }

      if (!found) {
        wrongAttempts++;
        errorMessage = '🚫  محاولة خاطئة  يا تملي(${5 - wrongAttempts})';
        _shakeController.forward(from: 0);
      } else {
        errorMessage = '🎊 أحسنت! استمر في التخمين';
      }
    });

    if (wrongAttempts >= 5) {
      await Future.delayed(const Duration(milliseconds: 300));
      _showCustomDialog(
        title: 'انتهت المحاولات! 😢',
        message: 'حاول مرة أخرى يا جلهووم وكن أكثر حذراً',
        icon: Icons.sentiment_very_dissatisfied,
        color: Colors.red,
      );
    } else if (revealedLetters.every((r) => r)) {
      await Future.delayed(const Duration(milliseconds: 300));
      _showCustomDialog(
        title: 'فزت! 🎉',
        message: 'أنت ابن شرنوب البار !',
        icon: Icons.celebration,
        color: Colors.green,
      );
    }

    _letterController.clear();
  }

  void _showCustomDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 72, color: Colors.white),
              const SizedBox(height: 20),
              Text(title,
                  style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Text(message,
                  style: const TextStyle(fontSize: 20, color: Colors.white)),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => Navigator.popUntil(
                        context, (route) => route.isFirst),
                    child: const Text('الصفحة الرئيسية',
                        style: TextStyle(color: Colors.black)),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text('إغلاق',
                        style: TextStyle(color: color.withOpacity(0.9))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4568DC), Color(0xFFB06AB3)])),
        child: Column(
          children: [
            AppBar(
              title: const Text('تخمين الحروف',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Badge(
                    label: Text('${5 - wrongAttempts}'),
                    backgroundColor: Colors.amber,
                    child: const Icon(Icons.favorite, color: Colors.red, size: 32),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final shakeValue = _shakeController.value * 20;
                  return Transform.translate(
                    offset: Offset(
                        shakeValue * (wrongAttempts.isOdd ? 1 : -1), 0),
                    child: child,
                  );
                },
                child: TextField(
                  controller: _letterController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  maxLength: 1,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                    hintText: '...اكتب حرفًا واحدًا',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, size: 32, color: Colors.white),
                      onPressed: _checkLetter,
                    ),
                  ),
                  onSubmitted: (_) => _checkLetter(),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                errorMessage,
                key: ValueKey(errorMessage),
                style: TextStyle(
                  color: errorMessage.contains('🎊') ? Colors.green : Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: List.generate(widget.word.length, (index) {
                return AnimatedCard(
                  revealed: revealedLetters[index],
                  letter: widget.word[index],
                  index: index,
                );
              }).reversed.toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedCard extends StatelessWidget {
  final bool revealed;
  final String letter;
  final int index;

  const AnimatedCard(
      {super.key,
        required this.revealed,
        required this.letter,
        required this.index});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.elasticOut,
      switchOutCurve: Curves.easeInBack,
      transitionBuilder: (child, animation) => Rotation3DTransition(
        animation: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: revealed
          ? _RevealedCard(letter: letter, index: index)
          : _HiddenCard(index: index),
    );
  }
}

class _RevealedCard extends StatelessWidget {
  final String letter;
  final int index;

  const _RevealedCard({required this.letter, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.lightGreenAccent, Colors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Text(letter,
            style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }
}

class _HiddenCard extends StatelessWidget {
  final int index;

  const _HiddenCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade300, Colors.indigo.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Text('?',
            style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.7))),
      ),
    );
  }
}

class Rotation3DTransition extends AnimatedWidget {
  const Rotation3DTransition({
    super.key,
    required this.animation,
    required this.child,
  }) : super(listenable: animation);

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateY(animation.value * pi * 2),
      alignment: Alignment.center,
      child: child,
    );
  }
}