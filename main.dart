import 'package:flutter/material.dart';
import 'package:kur_donusturucu/anasayfa.dart';

void main() {
  runApp(AnaUygulama());
}

class AnaUygulama extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: HomePage(),
    );
  }
}
