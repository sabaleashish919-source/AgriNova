import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double height;
  final bool compact;

  const BrandLogo({super.key, this.height = 58, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/agrinova_logo.png',
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'AgriNova',
    );
  }
}
