import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/firebase_provider.dart';
import 'screens/firebase_test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const CLEVOProFirebaseTest());
}

class CLEVOProFirebaseTest extends StatelessWidget {
  const CLEVOProFirebaseTest({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FirebaseProvider()..initialize(),
      child: MaterialApp(
        title: 'CLEVO Pro - Firebase Test',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const FirebaseTestScreen(),
      ),
    );
  }
}
