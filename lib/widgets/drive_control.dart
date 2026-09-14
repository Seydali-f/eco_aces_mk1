import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/rover_state.dart';
import '../theme.dart';
import 'shapes/hexagon.dart';
import 'ui/glass_panel.dart';

class DriveControlPanel extends StatefulWidget {
  const DriveControlPanel({Key? key}) : super(key: key);

  @override
  State<DriveControlPanel> createState() => _DriveControlPanelState();
}

class _DriveControlPanelState extends State<DriveControlPanel> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final roverState = context.read<RoverState>();
      switch (event.logicalKey) {
        case LogicalKeyboardKey.keyW:
          roverState.sendCommand('W', 'FORWARD');
          break;
        case LogicalKeyboardKey.keyS:
          roverState.sendCommand('S', 'BACKWARD');
          break;
        case LogicalKeyboardKey.keyA:
          roverState.sendCommand('A', 'TURN LEFT');
          break;
        case LogicalKeyboardKey.keyD:
          roverState.sendCommand('D', 'TURN RIGHT');
          break;
        case LogicalKeyboardKey.keyQ:
          roverState.sendCommand('Q', 'FORWARD LEFT');
          break;
        case LogicalKeyboardKey.keyE:
          roverState.sendCommand('E', 'FORWARD RIGHT');
          break;
        case LogicalKeyboardKey.space:
          roverState.stopRover();
          break;
      }
    } else if (event is KeyUpEvent) {
      final roverState = context.read<RoverState>();
      if (event.logicalKey != LogicalKeyboardKey.space) {
        roverState.releaseCommand();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: GlassPanel(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('DRIVE CONTROL', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryText, fontSize: 12)),
            const SizedBox(height: 32),
            
            // Top row: Q, W, E
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDriveKey(context, 'Q', 'FORWARD LEFT'),
                const SizedBox(width: 4),
                _buildDriveKey(context, 'W', 'FORWARD'),
                const SizedBox(width: 4),
                _buildDriveKey(context, 'E', 'FORWARD RIGHT'),
              ],
            ),
            const SizedBox(height: 4),
            
            // Middle row: A, STOP, D
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDriveKey(context, 'A', 'TURN LEFT'),
                const SizedBox(width: 4),
                _buildStopKey(context),
                const SizedBox(width: 4),
                _buildDriveKey(context, 'D', 'TURN RIGHT'),
              ],
            ),
            const SizedBox(height: 4),
            
            // Bottom row: S
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDriveKey(context, 'S', 'BACKWARD'),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDriveKey(BuildContext context, String label, String cmdName) {
    final roverState = context.watch<RoverState>();
    final isActive = roverState.currentCommand == cmdName;

    return GestureDetector(
      onTapDown: (_) => context.read<RoverState>().sendCommand(label, cmdName),
      onTapUp: (_) => context.read<RoverState>().releaseCommand(),
      onTapCancel: () => context.read<RoverState>().releaseCommand(),
      child: HexagonWidget(
        width: 65,
        height: 75,
        color: isActive ? AppTheme.infoBlue : const Color(0xFF2B303B),
        hasGlow: isActive,
        glowColor: AppTheme.infoBlue,
        isPressed: isActive,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : AppTheme.secondaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildStopKey(BuildContext context) {
    final roverState = context.watch<RoverState>();
    final isStopped = roverState.currentCommand == 'STOPPED';

    return GestureDetector(
      onTapDown: (_) => context.read<RoverState>().stopRover(),
      child: HexagonWidget(
        width: 75,
        height: 85,
        color: AppTheme.stopOrange,
        hasGlow: true,
        glowColor: AppTheme.stopOrange,
        isPressed: isStopped,
        child: const Text(
          'STOP',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
