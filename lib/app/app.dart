import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class AgroSurplusApp extends StatelessWidget {
  const AgroSurplusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AgroSurplus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
