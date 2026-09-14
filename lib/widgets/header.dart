import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rover_state.dart';
import '../theme.dart';
import 'dart:async';

class Header extends StatefulWidget {
  const Header({Key? key}) : super(key: key);

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  late Timer _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, top: 32, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Titles
          // Left: Titles
          Builder(builder: (context) {
            final state = context.watch<RoverState>();
            String title = 'Dashboard';
            String subtitle = 'High level operational overview';
            switch (state.currentTab) {
              case 1:
                title = 'Map & People';
                subtitle = 'Spatial tracking and map location';
                break;
              case 2:
                title = 'Sensors';
                subtitle = 'Environmental safety monitoring';
                break;
              case 3:
                title = 'History';
                subtitle = 'System logs and event timeline';
                break;
              case 4:
                title = 'Settings';
                subtitle = 'System configuration';
                break;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
              ],
            );
          }),

          // Right: Statuses
          Row(
            children: [
              const Icon(Icons.shield, color: AppTheme.safeGreen, size: 16),
              const SizedBox(width: 6),
              const Text('Semnary 2y', style: TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
              const SizedBox(width: 24),
              Text(_currentTime, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              const SizedBox(width: 24),
              
              // Bell Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.panel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Icon(Icons.notifications, color: AppTheme.dangerRed, size: 16),
              ),
              const SizedBox(width: 12),
              
              // Profile Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.panel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Icon(Icons.person, color: AppTheme.primaryText, size: 16),
              ),
            ],
          )
        ],
      ),
    );
  }
}
