import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class AgriNovaApp extends StatelessWidget {
  const AgriNovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AgriNova',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
