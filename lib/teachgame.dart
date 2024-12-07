import 'dart:async';

import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool gameHasStarted = false;
  bool gameOver = false;
    int score = 0;
  int highscore = 0;

  // Movement and physics constants
  static const double gravity = 15.0;
  static const double jumpVelocity = 10.0;
  double velocityY = 0.0;

  // Positioning variables
  
  late double screenWidth;
  late double screenHeight;
  late double dinoSize;
  late double widthofPlant;
  late double heightofPlant;
  double dinoBottomPosition = 0;
  double dinoleftPosition = 0;
  double obstacleXPosition = 0;
double obstacleYPosition = 0;

  Timer? gameLoopTimer;

    void startGame() {
    setState(() {
      gameHasStarted = true;
      gameOver = false;
    });

     void updatePhysics() {
    setState(() {
      // Gravity and jump physics
      velocityY -= gravity * (0.014); // Adjust for frame rate
      dinoBottomPosition += velocityY * (screenHeight/400); // Adjust for frame rate
     
    });
  }

    // Game loop
    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 5), (timer) {
      updatePhysics();

    });
  }

    @override
  void dispose() {
    gameLoopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(body: 
    GestureDetector(child: 
    Stack(children: [


        Positioned(
          child: Container(
            color: const Color.fromARGB(255, 255, 206, 206),
            child: Image.asset(
              "optimbg.gif",
              fit: BoxFit.fitHeight,
              repeat: ImageRepeat.repeatX,
            ),
          ),
        ),

        // Score Display
        Positioned(
          top: 30, // Moved 20 units higher
          left: 0,
          right: 0,
          child: Center(
          child: Text(
            'Score: $score | High Score: $highscore',
            style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            ),
          ),
          ),
        ),

        // Dino
        Positioned(
          bottom: dinoBottomPosition + (screenHeight*0.3), // Moved 20 units higher
          left: dinoleftPosition,
          child: Container(
          width: dinoSize,
          height: dinoSize,
          decoration: BoxDecoration(
          border: Border.all(
          color: Colors.black,
          width: 2.0,
          ),
          ),
          child: Image.asset(
            'finwithpav.gif',
            fit: BoxFit.contain,
          ),
          ),
        ),

        // Obstacle
        Positioned(
          bottom: (screenHeight*0.3), // Moved 20 units higher
          left: obstacleXPosition,
          child: Container(
          height: heightofPlant,
          width: widthofPlant,
          decoration: BoxDecoration(
          border: Border.all(
          color: Colors.black,
          width: 2.0,
          ),
          ),
          child: Image.asset(
          'reactobstacle.png',
          fit: BoxFit.contain,
          ),
          ),
        ),



      if (gameOver)
          Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const Text(
              'Game Over!',
              style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: playAgain,
              child: const Text('Play Again'),
            ),
            ],
          ),
          ),
      if (!gameHasStarted)
          Center(
          child: ElevatedButton(
            onPressed: startGame,
            child: const Text('Start Game'),
          ),
          ),
    ],),
    ),
    );
  }

  void playAgain() {
  }


}