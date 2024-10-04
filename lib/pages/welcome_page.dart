import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartchair/models/utils.dart';
import 'package:smartchair/database/database_services.dart';
import 'package:smartchair/pages/loading_page.dart';
import 'package:smartchair/pages/counter_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String _userName = '';
  String _displayedWelcomeText = '';
  String _displayedSitText = '';
  final String _welcomeTextPrefix = 'Seja bem-vindo(a), ';
  final String _sitText = 'Sente-se na cadeira...';
  Timer? _welcomeTimer;
  Timer? _sitTimer;
  int _welcomeTextIndex = 0;
  int _sitTextIndex = 0;
  bool _isSeated = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  void _fetchUserName() async {
    final userName = await DatabaseService().getName();
    setState(() {
      _userName = userName;
    });
    _startTypingWelcomeAnimation();
  }

  @override
  void dispose() {
    _welcomeTimer?.cancel();
    _sitTimer?.cancel();
    super.dispose();
  }

  void _startTypingWelcomeAnimation() {
    _welcomeTimer = Timer.periodic(const Duration(milliseconds: 130), (timer) {
      if (_welcomeTextIndex < _welcomeTextPrefix.length) {
        setState(() {
          _displayedWelcomeText += _welcomeTextPrefix[_welcomeTextIndex];
          _welcomeTextIndex++;
        });
      } else if (_welcomeTextIndex == _welcomeTextPrefix.length) {
        setState(() {
          _displayedWelcomeText += _userName;
          _welcomeTextIndex++;
        });
        _welcomeTimer?.cancel();
        _startTypingSitAnimation();
      }
    });
  }

  void _startTypingSitAnimation() {
    _sitTimer = Timer.periodic(const Duration(milliseconds: 130), (timer) {
      if (_sitTextIndex < _sitText.length) {
        setState(() {
          _displayedSitText += _sitText[_sitTextIndex];
          _sitTextIndex++;
        });
      } else {
        _sitTimer?.cancel();
      }
    });
  }

  void _onButtonPressed() async {
    setState(() {
      _isSeated = true;
    });

    await Future.delayed(const Duration(milliseconds: 450));

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoadingPage()),
    );

    await Future.delayed(const Duration(milliseconds: 450));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CounterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utils.darkBlue,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chair_alt,
                  size: 40,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  'SMARTCHAIR®',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _displayedWelcomeText,
              style: const TextStyle(fontSize: 24, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              _displayedSitText,
              style: const TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_sitTextIndex >= _sitText.length) ...[
              Center(
                child: _isSeated
                    ? const Icon(Icons.check_circle, color: Colors.white, size: 30)
                    : const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.0,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHovered = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (_isHovered ||
                              states.contains(WidgetState.pressed)) {
                            return Colors.white.withOpacity(0.7);
                          }
                          return Colors.white.withOpacity(0.3);
                        },
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (_isHovered ||
                              states.contains(WidgetState.pressed)) {
                            return Utils.darkBlue;
                          }
                          return Colors.white;
                        },
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    onPressed: _onButtonPressed,
                    child: const Text(
                      'Já estou sentado(a)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
