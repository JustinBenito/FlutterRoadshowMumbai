import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  // Game state variables
  bool gameHasStarted = false;
  bool gameOver = false;
  bool midJump = false;
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
  late double obstacleSize;
  double dinoBottomPosition = 0;
  double dinoleftPosition = 0;
  double obstacleXPosition = 0;
double obstacleYPosition = 0;

double cloud1=Random().nextDouble()/3;
double cloud2=Random().nextDouble()/3;
double cloud3=Random().nextDouble()/3;

  // Game loop timer
  Timer? gameLoopTimer;
  Timer? obstacleTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    // Set responsive sizing
    dinoleftPosition = screenWidth * 0.1;
    dinoSize = screenHeight * 0.20;
    obstacleSize = screenHeight * 0.15;
    widthofPlant = screenHeight * 0.06;
  }

  void jump() {
    if (!midJump && gameHasStarted && !gameOver) {
      setState(() {
        midJump = true;
        velocityY = jumpVelocity;
              dinoleftPosition += screenWidth * 0.005;
      });
    }
  }

  void updatePhysics() {
    setState(() {
      // Gravity and jump physics
      velocityY -= gravity * (0.014); // Adjust for frame rate
      dinoBottomPosition += velocityY * (screenHeight/400); // Adjust for frame rate

      // Landing check
      if (dinoBottomPosition <= 0) {
        dinoBottomPosition = 0;
        midJump = false;
        velocityY = 0;
      }

      // Move obstacle
      obstacleXPosition -= screenHeight * 0.004;
      
      if (obstacleXPosition < screenWidth * 0.1 ) {
        obstacleXPosition -= screenHeight * 0.04;

      }

      // Reset obstacle when off-screen
      if (obstacleXPosition < screenWidth * 0.001 ) {
        obstacleXPosition = screenWidth;
        score++;
      }
    });
  }

  bool detectCollision() {
    // Simple collision detection
    double dinoXposition=screenWidth * 0.1;
    print('Collision detected: dinoXposition:$dinoXposition, obstacleXPosition=$obstacleXPosition, dinoBottomPosition=$dinoBottomPosition, obstacleSize=$obstacleSize, dinosize=$dinoSize,velocityY=$velocityY, obstacleYPosition=$obstacleYPosition');

    bool collision = ( dinoXposition<obstacleXPosition+(widthofPlant/2) && obstacleXPosition < screenWidth*0.2 && dinoBottomPosition < obstacleSize);
    if (collision) {
      print('Collision detected: dinoXposition:$dinoXposition, obstacleXPosition=$obstacleXPosition, dinoBottomPosition=$dinoBottomPosition, obstacleSize=$obstacleSize, dinosize=$dinoSize, velocityY=$velocityY, obstacleYPosition=$obstacleYPosition');
    }
    return collision;

  }

  void startGame() {
    setState(() {
      gameHasStarted = true;
      gameOver = false;
      score = 0;
      dinoBottomPosition = 0;
      obstacleXPosition = screenWidth;
    });

    // Game loop
    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 5), (timer) {
      updatePhysics();

      if (detectCollision()) {
        gameOver = true;
        timer.cancel();
        
        if (score > highscore) {
          setState(() {
            highscore = score;
          });
        }
      }
    });
  }

  void playAgain() {
    startGame();
  }

  @override
  void dispose() {
    gameLoopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
      onTap: () {
        if (gameOver) {
        playAgain();
        } else {
        jump();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
        // Background


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
          height: obstacleSize,
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

        // Game Over Overlay
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

        // Start Game Overlay
        if (!gameHasStarted)
          Center(
          child: ElevatedButton(
            onPressed: startGame,
            child: const Text('Start Game'),
          ),
          ),
        ],
      ),
      ),
    );
  }
}