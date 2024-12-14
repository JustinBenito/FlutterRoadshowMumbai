// import 'dart:async';

// import 'package:flutter/material.dart';

// class GameScreen extends StatefulWidget {
//   const GameScreen({super.key});

//   @override
//   State<GameScreen> createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> {

//   bool gameHasStarted = false;
//   bool gameOver = false;

//     bool isInJumpState = false;
//   int score = 0;
//   int highScore = 0;

//   // Movement and physics constants
//   final double gravity = 15.0;
//   final double jumpVelocity = 10.0;
//   double velocityY = 0.0;
// Timer? gameLoopTimer;
//   // Positioning variables
//   late double screenWidth;
//   late double screenHeight;
//   late double dinoSize;
//   late double widthOfObstacle;
//   late double heightOfObstacle;
//   double dinoBottomPosition = 0;
//   double dinoleftPosition = 0;
//   double obstacleXPosition = 0;
//   double obstacleYPosition = 0;


// @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     screenWidth = MediaQuery.of(context).size.width;
//     screenHeight = MediaQuery.of(context).size.height;
//     // Set responsive sizing
//     dinoleftPosition = screenWidth * 0.1;
//     dinoSize = screenHeight * 0.20;
//     heightOfObstacle = screenHeight * 0.15;
//     widthOfObstacle = screenHeight * 0.06;
//   }

// void updatePhysics() {
//     setState(() {
//       // Gravity and jump physics
//       velocityY -= gravity * (0.014); 
      
//       // Adjust for frame rate
//       dinoBottomPosition += velocityY * (screenHeight / 400); // Adjust for frame rate
//       print("velocityY, $velocityY");


//       // Landing check
//       if (dinoBottomPosition <= 0) {
//         dinoBottomPosition = 0;
//         isInJumpState = false;
//         velocityY = 0;
//       }



//       // Move obstacle
//       obstacleXPosition -= screenHeight * 0.004;

//       if (obstacleXPosition < screenWidth * 0.1) {
//         obstacleXPosition -= screenHeight * 0.04;
//       }

//       // Reset obstacle when off-screen
//       if (obstacleXPosition < screenWidth * 0.001) {
//         obstacleXPosition = screenWidth;
//         score++;
//       }

      
//     });
//   }
// void jump() {
//     if (!isInJumpState && gameHasStarted && !gameOver) {
//       setState(() {
//         isInJumpState = true;
//         velocityY = jumpVelocity;
//         dinoleftPosition += screenWidth * 0.005;
//       });
//     }
//   }


// bool detectCollision() {
//     bool collision =
//         (dinoleftPosition < obstacleXPosition + (widthOfObstacle / 2) &&
//             obstacleXPosition < screenWidth * 0.2 &&
//             dinoBottomPosition < heightOfObstacle);
//     return collision;
//   }

// void startGame() {
//   setState(() {
//     gameHasStarted = true;
//     gameOver = false;
//   });

//   gameLoopTimer = Timer.periodic(const Duration(milliseconds: 5), (timer) {
//       updatePhysics();

//       if (detectCollision()) {
//         gameOver = true;
//         timer.cancel();

//         if (score > highScore) {
//           setState(() {
//             highScore = score;
//           });
//         }
//       }
//     });
// }

// @override
// void dispose() {
//   gameLoopTimer?.cancel();
//   super.dispose();
// }

//   @override
//   Widget build(BuildContext context) {
//    return Scaffold(
//   body: GestureDetector(
//     onTap: () => jump(),
//     child: Stack(
//       children: [
//         if (gameOver)
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Game Over!',
//                   style: TextStyle(
//                     fontSize: 40,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: startGame,
//                   child: const Text('Play Again'),
//                 ),
//               ],
//             ),
//           ),

//           Stack(
//           fit: StackFit.expand,
//           children: [
//             // Background
//             Positioned(
//               child: Container(
//                 color: const Color.fromARGB(255, 255, 206, 206),
//                 child: Image.asset(
//                   "optimbg.gif",
//                   fit: BoxFit.fitHeight,
//                   repeat: ImageRepeat.repeatX,
//                 ),
//               ),
//             ),

//             // Score Display
//             Positioned(
//               top: 30, // Moved 30 units higher
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Text(
//                   'Score: $score | High Score: $highScore',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),

//             // Dino
//             Positioned(
//               bottom: dinoBottomPosition +
//                   (screenHeight * 0.3), // Moved 20 units higher
//               left: dinoleftPosition,
//               child: Container(
//                 width: dinoSize,
//                 height: dinoSize,
//                 child: Image.asset(
//                   'finwithpav.gif',
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),

//             // Obstacle
//             Positioned(
//               bottom: (screenHeight * 0.3), // Moved 20 units higher
//               left: obstacleXPosition,
//               child: Container(
//                 height: heightOfObstacle,
//                 width: widthOfObstacle,
//                 child: Image.asset(
//                   'reactobstacle.png',
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),

//             // Game Over Overlay
//             if (gameOver)
//               Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Game Over!',
//                       style: TextStyle(
//                         fontSize: 40,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: startGame,
//                       child: const Text('Play Again'),
//                     ),
//                   ],
//                 ),
//               ),

//             // Start Game Overlay
//             if (!gameHasStarted)
//               Column(
//                 children: [
//                   Image.asset(
//                     "dashrun.png",
//                     fit: BoxFit.fitHeight,
//                   ),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: startGame,
//                       child: const Text('Start Game'),
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),

//         if (!gameHasStarted)
//           Center(
//             child: ElevatedButton(
//               onPressed: startGame,
//               child: const Text('Start Game'),
//             ),
//           ),
//       ],
//     ),
//   ),
// );

//   }

// Not required now
// }