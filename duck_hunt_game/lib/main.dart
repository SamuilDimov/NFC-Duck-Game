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

class _GameHomePageState extends State<GameHomePage> {
  // Function to check NFC availability
  Future<bool> checkNFC() async {
    bool isNfcAvailable = await NfcManager.instance.isAvailable();
    return isNfcAvailable;
  }

  // Function to start NFC session
  void startNFCSession() {
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        // Handle NFC tag discovery
        print("NFC Tag discovered: $tag");
        // 
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Duck Hunt Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to NFC Duck Hunt!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool nfcAvailable = await checkNFC();
                if (nfcAvailable) {
                  startNFCSession();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('NFC Unavailable'),
                      content: Text('NFC is not available or not enabled on this device.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Start NFC Scan'),
            ),
            // Additional game UI elements can be added here
          ],
        ),
      ),
    );
  }
}
