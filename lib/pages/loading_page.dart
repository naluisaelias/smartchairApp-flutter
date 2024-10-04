import 'package:flutter/material.dart';
import 'package:smartchair/models/utils.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      backgroundColor: Utils.darkBlue,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Utils.orange),
        ),
      ),
    );
  }
}
