import 'package:flutter/material.dart';
import 'package:smartchair/models/utils.dart';
import 'package:smartchair/pages/live_monitoring_page.dart';
import 'package:smartchair/pages/loading_page.dart';
import 'package:smartchair/database/database_services.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String userName = '';
  Map<String, int> sideTimes = {
    'Direito': 0,
    'Esquerdo': 0,
    'Frente': 0,
    'Trás': 0,
  };

  final int totalDuration = 30;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchSideTimes();
  }

  Future<void> _fetchUserName() async {
    String fetchedName = await DatabaseService().getName();
    setState(() {
      userName = fetchedName;
    });
  }

  Future<void> _fetchSideTimes() async {
    try {
      Map<String, int> counts = await DatabaseService().getContLadoTorto();
      setState(() {
        sideTimes = {
          'Direito': counts['Direito'] ?? 0,
          'Esquerdo': counts['Esquerdo'] ?? 0,
          'Frente': counts['Frente'] ?? 0,
          'Trás': counts['Trás'] ?? 0,
        };
      });
    } catch (e) {
      print('Erro ao buscar contagens de lado torto: $e');
    }
  }

  void _navigateToLiveMonitoring() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoadingPage()),
    );
    
    await Future.delayed(Duration(milliseconds: 450));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LiveMonitoringPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utils.darkBlue,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monitore sua saúde, $userName!',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Você sabia que apenas 30 segundos podem ser significativos para sua postura?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 35,
                mainAxisSpacing: 35,
                padding: EdgeInsets.zero,
                children: [
                  _buildProgressCard('Tempo com a postura inclinada para a direita', sideTimes['Direito'] ?? 0),
                  _buildProgressCard('Tempo com a postura inclinada para a esquerda', sideTimes['Esquerdo'] ?? 0),
                  _buildProgressCard('Tempo com a postura inclinada para a frente', sideTimes['Frente'] ?? 0),
                  _buildProgressCard('Tempo com a postura inclinada para trás', sideTimes['Trás'] ?? 0),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: TextButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return Colors.white.withOpacity(0.1);
                    },
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return Colors.white;
                    },
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                onPressed: _navigateToLiveMonitoring,
                child: Text(
                  'Monitoramento ao vivo da postura',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
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
    );
  }

  Widget _buildProgressCard(String title, int seconds) {
    double percentage = seconds > totalDuration ? 1.0 : (seconds / totalDuration);
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Utils.darkBlue,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              value: percentage,
              strokeWidth: 4,
              color: Utils.darkBlue,
            ),
          ),
          SizedBox(height: 5),
          Text(
            '${(percentage * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              color: Utils.darkBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
