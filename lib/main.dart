import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'providers/rover_state.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoverState()),
      ],
      child: const MineRescueApp(),
    ),
  );
}

class MineRescueApp extends StatelessWidget {
  const MineRescueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mine Rescue Rover - Command Center',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const DashboardScreen(),
    );
  }
}
