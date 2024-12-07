# My Article

we start with an empty stateful widget coz we know we need to update continously

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

we define a game started ? variable

```python
bool gameHasStarted = false;
  bool gameOver = false;
```

render a button that says to start the game with an empty function

```dart
return  Scaffold(body: 
    GestureDetector(child: 
    Stack(children: [
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
```

lets also define a game over screen just in case

```python
  bool gameOver = false;
```

<aside>

Give flutter run -d chrome

</aside>

Now lets define the startGame functions

```dart
    void startGame() {
    setState(() {
      gameHasStarted = true;
      gameOver = false;
    });
  }
```

Our game needs to update in milli seconds and it loops continously, so we need a timer to know to update the state and render it. We also need to start the timer. Also it is good practice to stop the timer so that there is no memory leakage.

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
 
  @override
  void dispose() {
    gameLoopTimer?.cancel();
    super.dispose();
  }
```

also import the dart:async library for the above Timer to work.

Now I want to update my game every 5 seconds, so I’ll call the updatePhysics function which will run continously during the timer 

```dart
   gameLoopTimer = Timer.periodic(const Duration(milliseconds: 5), (timer) {
      updatePhysics();

    });
```

We will define the updatePhysics function in a while.

But before that its importatnt to add some characters into picture, so that we know what do update continously in our game. 

Since we need the Dash, The background, The Obstacle and the High score content in the screen. I am going to add them into the screen UI inside the stack widget. 

```dart
    Stack(children: [

.
.
.

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
          top: 30, 
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
        
        
        .
        .
        .
        .
        .
        .
        
        ]

```

<aside>
🤔

Update the pubspec.yaml file for including the assets.

</aside>

Inorder for the above UI to make sense we may need to define few variables.

We would need

- score variable
- highscore variable
- width and height of the obstacle
- Size of Dash
- X and Y position of both Dash and the Obstacle
- How high Dash can jump → Jump Velocity
- How fast should Dash come down → Gravity
- Finally a variable to store the current velocity

<aside>
🤔

**Inorder to make the positioning responsive, all positioning is calculated in the multiples of the screen Height and screen Width.**

</aside>

So, lets define these in dart.

```dart
  int score = 0;
  int highscore = 0;

  // Movement and physics constants
  static const double gravity = 15.0;
  static const double jumpVelocity = 10.0;
  double velocityY = 0.0;
  bool isInJumpState = false;
  
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
```

Now since we are defining the screenHeight and the screenWidth we need to get the values from MediaQuery.
To get these global values and inorder to update the entire app incase the WIdth and Height changes, we will need to get these values when the app loads.

But if we use initstate we would not be able to get the context of the app which is a requirement for MediaQuery, so we go with didChangeDependencies()

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
    heightofPlant = screenHeight * 0.15;
    widthofPlant = screenHeight * 0.06;
  }
```

<aside>
🔥

If you have crossed this much, kudos to you. You are doing great. 

</aside>

We have done much of the initializing and defining part, 

it is time to write the juicy parts. The logic.

The logical parts in our code that we need to solve is

1️⃣ Letting the game run 

- Updating the Physics of the app continously
- Jump on tap

2️⃣ Not let the game run ( end game )

- Detect if there is a collision between Dash and the Obstacle.

Lets define the jump and detectCollision functions.

```dart

void updatePhysics() {

}

void jump() {
    
}

bool detectCollision() {
    
}

```

the updatePhysics() function will take care of everything that should be taken care of every second of the game. From the dino game we can easily infer that 3 main things happen.

- The dino(Dash) physics movement (jump) is taken care
- movement of the obstacles is taken care of
- the score card is noted

So we make the updatePhysics function to take care of all of the above.

<aside>
🔥

**Explanation of Jump:**

To make sure that our Jump is smooth, we can define the  Jump and Land functionality in the updatePhysics function itself. The way we do this without breaking the game is by having the velocity to 0 until the user jumps, so our Dash will still be in its original position and when the user taps, the velocityY will be set to some finite value and the jump will take place. Also since we are subtracting continously in loop, we would need a base condition to check if the BottomPosition is a negative value and reset it to 0 and also change the state of Jump state, since we are not Jumping

**Explanation of Moving the Obstacles:**

We can move the obstacles by just simply subtracting bits of values from the screenHeight. The obstacle will initially be in the right most extreme away from the screen, so subtracting some finite bit of value will help it come towards the left. 

But just plainly subtracting wont do the job as we need to also reset the obstacle.
Incase the Obstacle has passed Dash without hitting, we can increment the score and reset the obstacle to again go to its initial position. 

To enhance and also make sure we don’t unnecessarily hit Dash, we can speed up the reseting process of the obstacle if it has gone past Dash. 

</aside>

```dart
void updatePhysics() {
    setState(() {
    
      // Gravity and Jump
      velocityY -= gravity * (0.014); 
      dinoBottomPosition += velocityY * (screenHeight/400); 
     
      // Landing check
      if (dinoBottomPosition <= 0) {
        dinoBottomPosition = 0;
        isInJumpState = false;
        velocityY = 0;
      }

      // Move obstacle
      obstacleXPosition -= screenHeight * 0.004;
      
      // Move obstacle faster since it has passed Dash
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
```

Now when it comes to the Jump function, since it executes when the users taps on the screen. 
We need to set the velocity to some finite value greater than 0 because thats how we have defined in the updatePhysics function. Also during the jump we ideally want our dash to move right a bit while jumping so we move a bit towards the right aswell.

Therefore the code will be

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

Now the main logic of the entire game, detecting if there is a collision.

<aside>
🔥

**Explanation:**

Conditions that should get satisfied for collision to happen are

- The position of the obstacle should be near Dash, since Dash is in the 10% of the screen, we can have a condition that checks if the obstacle is first in at least in the vicinity.
- We should also check the Y axis. So we check if the height of Dash is less than the height of the plant, which means this will continue.
- After all this if the edge of Dash intersects the obstacle we declare collision.
</aside>

```dart
  bool detectCollision() {
    bool collision = ( dinoleftPosition<obstacleXPosition+(widthofPlant/2) && obstacleXPosition < screenWidth*0.2 && dinoBottomPosition < heightofPlant);
    return collision;
  }
```

Now that our updatePhysics and detectCollision function is done we can implement this.

We can continuously check if there has been a collision and if so we would need to end the game, stop the timer and check for the score and update it accordingly. 

Also we would need to update the new variables. 

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
        
        if (score > highscore) {
          setState(() {
            highscore = score;
          });
        }
      }
    });
  }
```

and with that final addition our app is complete. 

You can run it in using the command

`flutter run -d chrome`

![NammaFlutter Dash Run](https://prod-files-secure.s3.us-west-2.amazonaws.com/a8267991-b303-4582-8325-29e9854dd726/0ad04cd2-3dd2-4a9e-8042-7d1a8197a8a6/Screenshot_2024-12-07_at_10.31.47_PM.png)