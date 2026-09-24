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
  String _currentDate = '';
  final List<String> _months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

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
      _currentDate = '${now.day} ${_months[now.month - 1]} ${now.year}';
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_tethering, color: AppTheme.safeGreen, size: 16),
              const SizedBox(width: 6),
              const Text('Telemetry OK', style: TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
              const SizedBox(width: 24),
              
              // Clock
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_currentTime, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Share Tech Mono')),
                  Text(_currentDate, style: const TextStyle(fontSize: 10, color: AppTheme.secondaryText, fontFamily: 'Share Tech Mono')),
                ],
              ),
              const SizedBox(width: 24),
              
              // Bell Icon
              const Icon(Icons.notifications, color: AppTheme.dangerRed, size: 20),
              const SizedBox(width: 16),
              
              // Profile Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.panel,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Icon(Icons.person, color: AppTheme.primaryText, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Operator 01', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.safeGreen)),
                          const SizedBox(width: 4),
                          const Text('Online', style: TextStyle(fontSize: 10, color: AppTheme.secondaryText)),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
