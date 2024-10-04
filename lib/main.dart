import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:smartchair/pages/intro_page.dart';
import 'package:smartchair/database/database_services.dart';
import 'package:smartchair/models/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  DatabaseService databaseService = DatabaseService();

  await databaseService.clearName();
  await databaseService.setLadoTortoFalse();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Chair',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Utils.orange,
          secondary: Utils.orange,
          surface: Utils.orange,
          error: Utils.orange,
        ),
      ),
      home: const IntroPage(),
    );
  }
}
