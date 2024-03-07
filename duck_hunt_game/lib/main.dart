import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

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

class GameHomePage extends StatefulWidget {
  @override
  _GameHomePageState createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> with SingleTickerProviderStateMixin {
  int scanCount = 3; // Start with 3 scans
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: false);

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);

    handleNFC();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handleNFC() async {
    if (await NfcManager.instance.isAvailable()) {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          print("NFC Tag discovered: $tag");
          setState(() {
            scanCount++;
          });
        }
      );
    } else {
      // Existing dialog for unavailable NFC
    }
  }

  // Method to decrement scan count
  void decrementScan() {
    if (scanCount > 0) {
      setState(() {
        scanCount--;
      });
    }
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
          // Background Image Container
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/sky.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                left: MediaQuery.of(context).size.width * _animation.value - 50,
                top: MediaQuery.of(context).size.height * 0.3,
                child: GestureDetector(
                  onTap: decrementScan,
                  child: child,
                ),
              );
            },
            child: Image.asset('assets/duck.png', width: 100),
          ),

          // Scans Text
          Positioned(
            right: 20,
            bottom: 20,
            child: Text(
              'Scans: $scanCount',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
