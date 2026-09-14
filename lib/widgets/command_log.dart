import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/rover_state.dart';
import '../theme.dart';
import 'ui/glass_panel.dart';

class CommandLogPanel extends StatelessWidget {
  const CommandLogPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roverState = context.watch<RoverState>();
    final logs = roverState.logs;

    return GlassPanel(
      padding: const EdgeInsets.all(24),
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OPERATOR COMMAND LOG', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryText)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(
                          DateFormat('HH:mm:ss').format(log.time),
                          style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          log.result,
                          style: const TextStyle(color: AppTheme.primaryText, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
