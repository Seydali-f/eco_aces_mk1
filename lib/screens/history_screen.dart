import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rover_state.dart';
import '../theme.dart';
import '../widgets/ui/glass_panel.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RoverState>();
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SYSTEM HISTORY & LOGS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: GlassPanel(
              padding: const EdgeInsets.all(24),
              child: ListView.separated(
                itemCount: state.logs.length,
                separatorBuilder: (context, index) => const Divider(color: AppTheme.border),
                itemBuilder: (context, index) {
                  final log = state.logs[index];
                  return ListTile(
                    leading: const Icon(Icons.history, color: AppTheme.secondaryText),
                    title: Text(log.command),
                    subtitle: Text(log.result),
                    trailing: Text(
                      DateFormat('HH:mm:ss').format(log.time),
                      style: const TextStyle(color: AppTheme.secondaryText),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
