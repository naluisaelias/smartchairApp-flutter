import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartchair/database/database_services.dart';
import 'package:smartchair/models/utils.dart';
import 'package:smartchair/pages/loading_page.dart';
import 'package:smartchair/pages/dashboards_page.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  static const int initialDuration = 30;
  int _remainingTime = initialDuration;
  int _contLadoDireito = 0;
  int _contLadoEsquerdo = 0;
  int _contLadoFrente = 0;
  int _contLadoTras = 0;
  Timer? _timer;
  bool _isCounting = false;
  String _message = 'Preparado? Fique sentado por 30 segundos!';
  bool _isHovered = false; 

  @override
  void initState() {
    super.initState();
  }

  void _startCounter() {
    setState(() {
      _isCounting = true;
      _message = 'Contagem iniciada! Mantenha-se confortável.';
      _resetCounters();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingTime > 0) {
        _remainingTime--;
        await _checkLadoTorto();
      } else {
        _timer?.cancel();
        _isCounting = false;
        await _saveData();
        _resetTimer();
        _navigateToNextPages(); 
      }
      setState(() {});
    });
  }

  Future<void> _checkLadoTorto() async {
    try {
      final ladoTortoData = await DatabaseService().getLadoTorto();

      if (ladoTortoData['ladodireito'] == true) _contLadoDireito++;
      if (ladoTortoData['ladoesquerdo'] == true) _contLadoEsquerdo++;
      if (ladoTortoData['ladofrente'] == true) _contLadoFrente++;
      if (ladoTortoData['ladotras'] == true) _contLadoTras++;
    } catch (e) {
      print('Erro ao buscar dados do lado torto: $e');
    }
  }

  Future<void> _saveData() async {
    await DatabaseService().setContLadoTorto(
      counts: {
        'cont-ladodireito': _contLadoDireito,
        'cont-ladoesquerdo': _contLadoEsquerdo,
        'cont-ladofrente': _contLadoFrente,
        'cont-ladotras': _contLadoTras,
      },
    );
  }

  void _resetCounters() {
    _contLadoDireito = 0;
    _contLadoEsquerdo = 0;
    _contLadoFrente = 0;
    _contLadoTras = 0;
  }

  void _resetTimer() {
    _remainingTime = initialDuration;
  }

  void _navigateToNextPages() async {
    await Future.delayed(const Duration(milliseconds: 450));

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoadingPage()),
    );

    await Future.delayed(const Duration(milliseconds: 450));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utils.darkBlue,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: CircularProgressIndicator(
                      value: _isCounting ? _remainingTime / initialDuration : 0,
                      strokeWidth: 10,
                      valueColor: const AlwaysStoppedAnimation<Color>(Utils.orange),
                    ),
                  ),
                  if (_remainingTime > 0)
                    Text(
                      '$_remainingTime',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (_remainingTime == 0)
                    const Icon(
                      Icons.check_circle,
                      size: 200,
                      color: Utils.orange,
                    ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                _message,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              if (!_isCounting) 
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
                        minimumSize: WidgetStateProperty.all(const Size(200, 60)),
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (_isHovered || states.contains(WidgetState.pressed)) {
                              return Colors.white.withOpacity(0.7);
                            }
                            return Colors.white.withOpacity(0.3);
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (_isHovered || states.contains(WidgetState.pressed)) {
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
                      onPressed: _startCounter,
                      child: const Text(
                        'Iniciar Contagem',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 40),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chair_alt,
                    size: 30,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'SMARTCHAIR®',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
