import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/ui/glass_panel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SYSTEM SETTINGS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: GlassPanel(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NETWORK CONFIGURATION', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.infoBlue)),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'ESP32 IP Address',
                      hintText: '192.168.4.1',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Python Flask Backend IP',
                      hintText: '127.0.0.1:5000',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('PREFERENCES', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.infoBlue)),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Auto-connect on Startup'),
                    value: true,
                    onChanged: (bool value) {},
                  ),
                  SwitchListTile(
                    title: const Text('Dark Mode (Glassmorphism)'),
                    value: true,
                    onChanged: (bool value) {},
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.infoBlue),
                    child: const Text('SAVE SETTINGS', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
