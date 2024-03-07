import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Duck Hunt Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameHomePage(),
    );
  }
}

class Duck {
  late AnimationController controller;
  late Animation<double> animationX;
  late Animation<double> animationY;
  final double size;
  final Duration duration;
  final TickerProvider vsync;
  final bool moveLeftToRight;

  Duck({required this.size, required this.duration, required this.vsync, required this.moveLeftToRight}) {
    controller = AnimationController(duration: duration, vsync: vsync)..repeat(reverse: true);
    animationX = moveLeftToRight
        ? Tween<double>(begin: -1.0, end: 2.0).animate(controller)
        : Tween<double>(begin: 2.0, end: -1.0).animate(controller);
    animationY = Tween<double>(begin: 0.2, end: 0.8).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }
}

class GameHomePage extends StatefulWidget {
  @override
  _GameHomePageState createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> with TickerProviderStateMixin {
  int scanCount = 3;
  List<Duck> ducks = [];
  late Timer duckRegenerationTimer;
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    generateDucks(3);
    duckRegenerationTimer = Timer.periodic(Duration(seconds: 5), (_) {
      if (ducks.length < 6) {
        generateDucks(1);
      }
    });
    NfcManager.instance.isAvailable().then((bool isAvailable) {
      if (isAvailable) {
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            print("NFC Tag discovered: $tag");
            setState(() {
              scanCount++;
            });
          }
        );
      }
    });
  }

  void generateDucks(int count) {
    for (int i = 0; i < count; i++) {
      double size = (math.Random().nextDouble() * 50) + 50;
      Duration duration = Duration(seconds: math.Random().nextInt(5) + 3);
      bool moveLeftToRight = math.Random().nextBool();

      setState(() {
        ducks.add(Duck(size: size, duration: duration, vsync: this, moveLeftToRight: moveLeftToRight));
      });
    }
  }

  void handleDuckTap(Duck duck) {
    if (scanCount > 0) {
      audioPlayer.play(AssetSource('quack.mp3'));  // Updated play method
      setState(() {
        ducks.remove(duck);
        scanCount--;
      });
    }
  }

  @override
  void dispose() {
    duckRegenerationTimer.cancel();
    audioPlayer.dispose();
    for (var duck in ducks) {
      duck.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Duck Hunt Game'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/sky.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          for (var duck in ducks)
            AnimatedBuilder(
              animation: duck.animationX,
              builder: (context, child) {
                return Positioned(
                  left: MediaQuery.of(context).size.width * duck.animationX.value - (duck.size / 2),
                  top: MediaQuery.of(context).size.height * duck.animationY.value - (duck.size / 2),
                  child: GestureDetector(
                    onTap: () => handleDuckTap(duck),
                    child: Image.asset('assets/duck.png', width: duck.size),
                  ),
                );
              },
            ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Text(
              'Scans: $scanCount',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
