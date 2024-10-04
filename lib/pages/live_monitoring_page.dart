import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartchair/models/utils.dart';
import 'package:smartchair/database/database_services.dart';

class LiveMonitoringPage extends StatefulWidget {
  @override
  _LiveMonitoringPageState createState() => _LiveMonitoringPageState();
}

class _LiveMonitoringPageState extends State<LiveMonitoringPage> {
  Map<String, bool> ladoTorto = {
    'encostodireito': false,
    'encostoesquerdo': false,
    'assentonafronte': false,
    'assentoatras': false,
  };

  String _displayedSitText = '';
  final String _sitText = 'Acompanhe sua postura em tempo real';
  Timer? _sitTimer;
  int _sitTextIndex = 0;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _fetchLadoTorto();
    _startPeriodicFetch();
    _startTypingSitAnimation();
  }

  @override
  void dispose() {
    _sitTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicFetch() {
    Future.delayed(Duration(seconds: 1), () {
      _fetchLadoTorto();
      _startPeriodicFetch();
    });
  }

  Future<void> _fetchLadoTorto() async {
    final fetchedData = await DatabaseService().getLadoTorto();
    
    if (fetchedData != null) {
      if (mounted) {
        setState(() {
          ladoTorto = {
            'encostodireito': fetchedData['ladodireito'] ?? false,
            'encostoesquerdo': fetchedData['ladoesquerdo'] ?? false,
            'assentonafronte': fetchedData['ladofrente'] ?? false,
            'assentoatras': fetchedData['ladotras'] ?? false,
          };
        });
      }
    } else {
      print('Dados de lado torto não disponíveis.');
    }
  }

  void _startTypingSitAnimation() {
    _sitTimer = Timer.periodic(Duration(milliseconds: 130), (timer) {
      if (_sitTextIndex < _sitText.length) {
        if (mounted) {
          setState(() {
            _displayedSitText += _sitText[_sitTextIndex];
            _sitTextIndex++;
          });
        }
      } else {
        _sitTimer?.cancel();
      }
    });
  }

  void _onBackButtonPressed() {
    Navigator.pop(context);
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
              Text(
                'Monitoramento da Postura',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                _displayedSitText,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.chair_alt,
                    size: 300,
                    color: Colors.white,
                  ),
                  Positioned(
                    top: 70, 
                    child: _buildDot(ladoTorto['assentoatras']!),
                  ),
                  Positioned(
                    bottom: 153,
                    child: _buildDot(ladoTorto['assentonafronte']!),
                  ),
                  Positioned(
                    top: 178,
                    left: 93,
                    child: _buildDot(ladoTorto['encostoesquerdo']!),
                  ),
                  Positioned(
                    top: 178,
                    right: 93,
                    child: _buildDot(ladoTorto['encostodireito']!),
                  ),
                ],
              ),
              SizedBox(height: 20),
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
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (_isHovered || states.contains(MaterialState.pressed)) {
                            return Colors.white.withOpacity(0.7);
                          }
                          return Colors.white.withOpacity(0.3);
                        },
                      ),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (_isHovered || states.contains(MaterialState.pressed)) {
                            return Utils.darkBlue;
                          }
                          return Colors.white;
                        },
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    onPressed: _onBackButtonPressed,
                    child: Text(
                      'Voltar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isActive ? Utils.orange : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
