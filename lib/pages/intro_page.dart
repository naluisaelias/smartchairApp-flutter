import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartchair/database/database_services.dart';
import 'package:smartchair/models/utils.dart';
import 'package:smartchair/pages/loading_page.dart';
import 'package:smartchair/pages/welcome_page.dart';
import 'package:smartchair/pages/live_monitoring_page.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final _nameController = TextEditingController();
  final _databaseService = DatabaseService();
  bool _isPressed = false;
  String _displayedText = '';
  final String _fullText = 'Digite seu nome:';
  Timer? _timer;
  int _textIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTypingAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  void _startTypingAnimation() {
    _timer = Timer.periodic(Duration(milliseconds: 130), (timer) {
      if (_textIndex < _fullText.length) {
        setState(() {
          _displayedText += _fullText[_textIndex];
          _textIndex++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _setUserName() async {
    final userName = _nameController.text;
    if (userName.isNotEmpty) {
      _databaseService.setName(userName);
      print('Nome do usuário: $userName');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoadingPage()),
      );

      Future.delayed(Duration(milliseconds: 450), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
        );
      });
    }
  }

  void _navigateToMonitoring() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoadingPage()),
    );

    Future.delayed(Duration(milliseconds: 450), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LiveMonitoringPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utils.darkBlue,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.chair_alt,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'SMARTCHAIR®',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _displayedText,
              style: TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Seu Nome',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTapDown: (_) => setState(() => _isPressed = true),
                  onTapUp: (_) {
                    setState(() => _isPressed = false);
                    _setUserName();
                  },
                  child: Icon(
                    _isPressed
                        ? Icons.arrow_circle_right_sharp
                        : Icons.arrow_circle_right_outlined,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _navigateToMonitoring,
              child: Text(
                'Ir para Monitoramento em Tempo Real',
                style: TextStyle(
                  color: Utils.orange,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
