# Flutter Dash Run Workshop

<aside>
💙 part of the workshop in Flutter Roadshow 2024 in mumbai

</aside>

We start with an empty stateful widget because we know we need to update the screen continuously with some state getting changed frequently.

```python
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

```

We define a `gameHasStarted` and `gameOver` variable to know if the game has started or not and render appropriate screens and buttons.

```python
bool gameHasStarted = false;
bool gameOver = false;

```

Render a button that says to start the game with an empty function for now called `startGame`

```dart
return Scaffold(
  body: GestureDetector(
    child: Stack(
      children: [
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
      ],
    ),
  ),
);

```

Now let's define the startGame function.

```dart
void startGame() {
  setState(() {
    gameHasStarted = true;
    gameOver = false;
  });
}

```

Our game needs to update in milliseconds and it loops continuously, so we need a timer to update the state and render it. It is also good practice to stop the timer to prevent memory leaks.

```dart
Timer? gameLoopTimer;

.
.
.
.
.
.

gameLoopTimer = Timer.periodic(const Duration(milliseconds: 5), (timer) {
  
});

.
.
.
.
.
.

@Override
void dispose() {
  gameLoopTimer?.cancel();
  super.dispose();
}

```

Also, import the `dart:async` library for the Timer to work.

Now I want to update my game every 5 milliseconds, so I’ll call the updatePhysics function which will run continuously during the timer.

```dart
gameLoopTimer = Timer.periodic(const Duration(milliseconds: 5), (timer) {
  updatePhysics();
});

```

We will define the updatePhysics function shortly.

But before that, it's important to add some characters to the picture so that we know what to update continuously in our game.

Since we need Dash, the background, the obstacle, and the high score content on the screen, I am going to add them to the screen UI inside the stack widget. I am also positioning them absolutely but it will become responsive once we define the screenHeight and screenWidth.

```dart
Stack(
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
              top: 30, // Moved 30 units higher
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
                  'thefin.gif',
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
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                child: Image.asset(
                  'obstacle.png',
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
                    "dashrun.png",
                    fit: BoxFit.fitHeight,
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
```

Update the `pubspec.yaml` file to include the assets.

In order for the above UI to make sense, we need to define a few variables.

We would need:

- score variable
- high score variable
- width and height of the obstacle
- size of Dash
- X and Y position of both Dash and the obstacle
- how high Dash can jump → jump velocity
- how fast Dash should come down → gravity
- finally, a variable to store the current velocity

<aside>
💙 **To make the positioning responsive, all positioning is calculated in multiples of the screen height and screen width.**

</aside>

So, let's define them

```dart
  bool isInJumpState = false;
  int score = 0;
  int highScore = 0;

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
```

Now, since we are defining the `screenHeight` and `screenWidth`, we need to get the values from `MediaQuery`. To get these global values and to update the entire app in case the width and height change, we will need to get these values when the app loads.

But if we use `initState`, we would not be able to get the context of the app, which is a requirement for MediaQuery, so we go with `didChangeDependencies()`.

Therefore, add this snippet of code to get the screenWidth and screenHeight and set responsive values for our characters in the game.

```dart
@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    // Set responsive sizing
    dinoleftPosition = screenWidth * 0.1;
    dinoSize = screenHeight * 0.20;
    heightOfObstacle = screenHeight * 0.15;
    widthOfObstacle = screenHeight * 0.06;
  }
```

> If you have made it this far, kudos to you. You are doing great!
> 

We have done much of the initializing and defining part.

It is time to write the juicy parts: the logic.

The logical parts in our code that we need to solve are:

1️⃣ Letting the game run:

- Updating the physics of the app continuously
- Jump on tap

2️⃣ Not letting the game run (end game):

- Detect if there is a collision between Dash and the obstacle.

Let's define the jump and detectCollision functions.

```dart
void updatePhysics() {}

void jump() {}

bool detectCollision() {}

```

The `updatePhysics()` function will take care of everything that should be taken care of every second of the game. From the dino game, we can easily infer that three main things happen:

- The dino (Dash) physics movement (jump) is taken care of.
- Movement of the obstacles is taken care of.
- The scorecard is updated.

So we make the `updatePhysics` function take care of all of the above.

**Explanation of Jump function:**

To make sure that our jump is smooth, we can define the jump and land functionality in the `updatePhysics` function itself. The way we do this without breaking the game is by having the velocity set to 0 until the user jumps, so our Dash will still be in its original position. When the user taps, the velocityY will be set to some finite value, and the jump will take place. Also, since we are subtracting continuously in the loop, we need a base condition to check if the bottom position is a negative value and reset it to 0, also changing the state of the jump state since we are not jumping.

**Explanation of Moving the Obstacles:**

We can move the obstacles by simply subtracting bits of values from the screen height. The obstacle will initially be in the rightmost extreme away from the screen, so subtracting some finite bit of value will help it come towards the left.

But just plainly subtracting won't do the job as we need to also reset the obstacle.
In case the obstacle has passed Dash without hitting, we can increment the score and reset the obstacle to again go to its initial position.

To enhance and also make sure we don’t unnecessarily hit Dash, we can speed up the resetting process of the obstacle if it has gone past Dash.

```dart
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
      }
    });
  }
```

Now, when it comes to the jump function, since it executes when the user taps on the screen, we need to set the velocity to some finite value greater than 0 because that's how we have defined it in the `updatePhysics` function. Also, during the jump, we ideally want our Dash to move right a bit while jumping, so we move a bit towards the right as well.

Therefore, the code will be:

```dart
void jump() {
    if (!isInJumpState && gameHasStarted && !gameOver) {
      setState(() {
        isInJumpState = true;
        velocityY = jumpVelocity;
        dinoleftPosition += screenWidth * 0.005;
      });
    }
  }
```

Now the main logic of the entire game: detecting if there is a collision.

**Explanation:**

Conditions that should be satisfied for a collision to happen are:

- The position of the obstacle should be near Dash. Since Dash is in the 10% of the screen, we can have a condition that checks if the obstacle is at least in the vicinity.
- We should also check the Y-axis. So we check if the height of Dash is less than the height of the plant, which means this will continue.
- After all this, if the edge of Dash intersects the obstacle, we declare a collision.

```dart
bool detectCollision() {
    bool collision =
        (dinoleftPosition < obstacleXPosition + (widthOfObstacle / 2) &&
            obstacleXPosition < screenWidth * 0.2 &&
            dinoBottomPosition < heightOfObstacle);
    return collision;
  }
```

Now that our `updatePhysics` and `detectCollision` functions are done, we can implement this.

We can continuously check if there has been a collision, and if so, we need to end the game, stop the timer, and check for the score to update it accordingly.

Also, we need to update the new variables.

```dart
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

        if (score > highScore) {
          setState(() {
            highScore = score;
          });
        }
      }
    });
  }
```

And with that final addition, our app is complete.

You can run it using the command:

`flutter run -d chrome`

### The Final App:
<img width="1469" alt="Screenshot 2024-12-07 at 11 04 05 PM" src="https://github.com/user-attachments/assets/1e05ff3e-832c-4a31-9ef5-d8f39ba7fbc4">