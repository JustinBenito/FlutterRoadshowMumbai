
import 'package:dash_run/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(DinoRunnerGame());
}

class DinoRunnerGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameScreen(),
    );
  }
}
