import 'package:flutter/material.dart';
import 'package:lens_button/lens_button.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: Stack(
          children: [
            Positioned(
              right: 12,
              bottom: -28,
              child: FlutterLogo(
                size: 100,
                style: FlutterLogoStyle.horizontal,
              ),
            ),
            Center(
              child: LensButton(),
            ),
          ],
        ),
      ),
    );
  }
}
