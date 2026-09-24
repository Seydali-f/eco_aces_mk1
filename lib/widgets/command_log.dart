import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/rover_state.dart';
import '../theme.dart';
import 'package:flutter/rendering.dart';
import 'ui/glass_panel.dart';

class MatchParentHeight extends SingleChildRenderObjectWidget {
  const MatchParentHeight({Key? key, Widget? child}) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMatchParentHeight();
}

class _RenderMatchParentHeight extends RenderProxyBox {
  @override
  double computeMaxIntrinsicHeight(double width) => 0.0;
  
  @override
  double computeMinIntrinsicHeight(double width) => 0.0;
}

class CommandLogPanel extends StatelessWidget {
  const CommandLogPanel({Key? key}) : super(key: key);

  Widget _buildLogItem(dynamic log) {
    // Determine icon and color based on command
    IconData cmdIcon = Icons.settings;
    Color cmdColor = AppTheme.secondaryText;
    String cmdText = log.command;
    
    if (log.command == 'FORWARD') {
      cmdIcon = Icons.arrow_upward;
      cmdColor = AppTheme.infoBlue;
      cmdText = 'Forward';
    } else if (log.command == 'BACKWARD') {
      cmdIcon = Icons.arrow_downward;
      cmdColor = AppTheme.infoBlue;
      cmdText = 'Backward';
    } else if (log.command == 'TURN LEFT') {
      cmdIcon = Icons.turn_left;
      cmdColor = AppTheme.infoBlue;
      cmdText = 'Turn Left';
    } else if (log.command == 'TURN RIGHT') {
      cmdIcon = Icons.turn_right;
      cmdColor = AppTheme.infoBlue;
      cmdText = 'Turn Right';
    } else if (log.command == 'FORWARD LEFT') {
      cmdIcon = Icons.turn_left;
      cmdColor = AppTheme.infoBlue;
      cmdText = 'Forward Left';
    } else if (log.command == 'FORWARD RIGHT') {
      cmdIcon = Icons.turn_right;
      cmdColor = AppTheme.infoBlue;
      cmdText = 'Forward Right';
    } else if (log.command == 'STOP') {
      cmdIcon = Icons.stop_circle;
      cmdColor = AppTheme.stopOrange;
      cmdText = 'Stop';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: cmdColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(cmdIcon, size: 14, color: cmdColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cmdText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(DateFormat('HH:mm:ss').format(log.time), style: const TextStyle(color: AppTheme.secondaryText, fontSize: 10, fontFamily: 'Share Tech Mono')),
              ],
            ),
          ),
          const Text('SUCCESS', style: TextStyle(color: AppTheme.safeGreen, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roverState = context.watch<RoverState>();
    final logs = roverState.logs;

    return MatchParentHeight(
      child: GlassPanel(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.infoBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.terminal,
                    color: AppTheme.infoBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'OPERATOR COMMANDS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryText,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.border, height: 1),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  // Show newest first
                  final log = logs[logs.length - 1 - index];
                  return _buildLogItem(log);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
