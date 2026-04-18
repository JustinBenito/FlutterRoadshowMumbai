import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  // Game state variables
  bool gameHasStarted = false;
  bool gameOver = false;
  bool isInJumpState = false;
  int score = 0;
  int highScore = 0;
  String gameOverMessage = '';

  // Random number generator for obstacle sizes
  final Random random = Random();

  // Focus node for keyboard input
  final FocusNode _focusNode = FocusNode();

  // Movement and physics constants
  final double gravity = 15.0;
  final double jumpVelocity = 10.0;
  double velocityY = 0.0;

  // Positioning variables
  late double screenWidth;
  late double screenHeight;
  late double dinoSize;
  late double widthOfObstacle;
  late double heightOfObstacle;
  double dinoBottomPosition = 0;
  double dinoleftPosition = 0;
  double obstacleXPosition = 0;
  double obstacleYPosition = 0;

  // Game loop timer
  Timer? gameLoopTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    // Set responsive sizing
    dinoleftPosition = screenWidth * 0.1;
    dinoSize = screenHeight * 0.20;
    randomizeObstacleSize();
  }

  void randomizeObstacleSize() {
    // Random size variations like the dino game (small, medium, large)
    double sizeMultiplier = 0.10 + random.nextDouble() * 0.10; // 0.10 to 0.20
    heightOfObstacle = screenHeight * sizeMultiplier;
    widthOfObstacle = screenHeight * (sizeMultiplier + 0.01);
  }

  String getRandomGameOverMessage() {
    List<String> messages = [
      'React won over Flutter!',
      'You gave up on Flutter!',
      'Flutter crashed!',
      'React.js strikes again!',
      'Dash is disappointed!',
      'Should have used React!',
      'Flutter? More like Stutter!',
      'JavaScript wins this round!',
    ];
    return messages[random.nextInt(messages.length)];
  }

  void handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        if (gameOver) {
          startGame();
        } else {
          jump();
        }
      }
    }
  }

  void jump() {
    if (!isInJumpState && gameHasStarted && !gameOver) {
      setState(() {
        isInJumpState = true;
        velocityY = jumpVelocity;
      });
    }
  }

  void updatePhysics() {
    setState(() {
      // Gravity and jump physics
      velocityY -= gravity * (0.014); // Adjust for frame rate
      dinoBottomPosition +=
          velocityY * (screenHeight / 400); // Adjust for frame rate
      print("velocityY, $velocityY");
      // Landing check
      if (dinoBottomPosition <= 0) {
        dinoBottomPosition = 0;
        isInJumpState = false;
        velocityY = 0;
      }

      // Move obstacle
      obstacleXPosition -= screenHeight * 0.004;

      if (obstacleXPosition < screenWidth * 0.1) {
        obstacleXPosition -= screenHeight * 0.04;
      }

      // Reset obstacle when off-screen
      if (obstacleXPosition < screenWidth * 0.001) {
        obstacleXPosition = screenWidth;
        score++;
        randomizeObstacleSize(); // Randomize size for next obstacle
      }
    });
  }

  bool detectCollision() {
    bool collision =
        (dinoleftPosition < obstacleXPosition + (widthOfObstacle / 2) &&
            obstacleXPosition < screenWidth * 0.2 &&
            dinoBottomPosition < heightOfObstacle);
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
        setState(() {
          gameOver = true;
          gameOverMessage = getRandomGameOverMessage();
        });
        timer.cancel();

        if (score > highScore) {
          setState(() {
            highScore = score;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    gameLoopTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: handleKeyPress,
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            if (gameOver) {
              startGame();
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
                  "assets/optimbg.gif",
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
                  'Score: $score | High Score: $highScore',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Dino
            Positioned(
              bottom: dinoBottomPosition +
                  (screenHeight * 0.3), // Moved 20 units higher
              left: dinoleftPosition,
              child: Container(
                width: dinoSize,
                height: dinoSize,
                child: Image.asset(
                  'assets/thefin.gif',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Obstacle
            Positioned(
              bottom: (screenHeight * 0.3), // Moved 20 units higher
              left: obstacleXPosition,
              child: Container(
                height: heightOfObstacle,
                width: widthOfObstacle,
                
                child: Image.asset(
                  'assets/reactobstacle.png',
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
                    Text(
                      gameOverMessage,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: startGame,
                      child: const Text('Play Again'),
                    ),
                  ],
                ),
              ),

            // Start Game Overlay
            if (!gameHasStarted)
              Column(
                children: [
                  Image.asset(
                    "assets/dashrun.png",
                    fit: BoxFit.fitWidth,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: startGame,
                      child: const Text('Start Game'),
                    ),
                  ),
                ],
              ),
          ],
          ),
        ),
      ),
    );
  }
}
