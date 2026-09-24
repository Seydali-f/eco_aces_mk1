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
    final roverState = context.read<RoverState>();
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.keyW:
          if (roverState.currentCommand != 'FORWARD') roverState.sendCommand('W', 'FORWARD');
          break;
        case LogicalKeyboardKey.keyS:
          if (roverState.currentCommand != 'BACKWARD') roverState.sendCommand('S', 'BACKWARD');
          break;
        case LogicalKeyboardKey.keyA:
          if (roverState.currentCommand != 'TURN LEFT') roverState.sendCommand('A', 'TURN LEFT');
          break;
        case LogicalKeyboardKey.keyD:
          if (roverState.currentCommand != 'TURN RIGHT') roverState.sendCommand('D', 'TURN RIGHT');
          break;
        case LogicalKeyboardKey.keyQ:
          if (roverState.currentCommand != 'FORWARD LEFT') roverState.sendCommand('Q', 'FORWARD LEFT');
          break;
        case LogicalKeyboardKey.keyE:
          if (roverState.currentCommand != 'FORWARD RIGHT') roverState.sendCommand('E', 'FORWARD RIGHT');
          break;
        case LogicalKeyboardKey.space:
          roverState.stopRover();
          break;
      }
    } else if (event is KeyUpEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.keyW:
        case LogicalKeyboardKey.keyS:
        case LogicalKeyboardKey.keyA:
        case LogicalKeyboardKey.keyD:
        case LogicalKeyboardKey.keyQ:
        case LogicalKeyboardKey.keyE:
          roverState.stopRover();
          break;
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
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top row: Q, W, E
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDriveKey(context, 'Q', 'FORWARD LEFT', Icons.turn_left),
                          const SizedBox(width: 4),
                          _buildDriveKey(context, 'W', 'FORWARD', Icons.arrow_upward),
                          const SizedBox(width: 4),
                          _buildDriveKey(context, 'E', 'FORWARD RIGHT', Icons.turn_right),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Middle row: A, STOP, D
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDriveKey(context, 'A', 'TURN LEFT', Icons.keyboard_arrow_left),
                          const SizedBox(width: 4),
                          _buildStopKey(context),
                          const SizedBox(width: 4),
                          _buildDriveKey(context, 'D', 'TURN RIGHT', Icons.keyboard_arrow_right),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Bottom row: S
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDriveKey(context, 'S', 'BACKWARD', Icons.arrow_downward),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriveKey(BuildContext context, String keyBind, String cmdName, IconData icon) {
    final roverState = context.watch<RoverState>();
    final isActive = roverState.currentCommand == cmdName;

    return GestureDetector(
      onTapDown: (_) => context.read<RoverState>().sendCommand(keyBind, cmdName),
      onTapUp: (_) => context.read<RoverState>().stopRover(),
      onTapCancel: () => context.read<RoverState>().stopRover(),
      child: HexagonWidget(
        width: 65,
        height: 75,
        color: isActive ? AppTheme.infoBlue : const Color(0xFF2B303B),
        hasGlow: isActive,
        glowColor: AppTheme.infoBlue,
        isPressed: isActive,
        child: Icon(
          icon,
          size: 28,
          color: isActive ? Colors.white : AppTheme.secondaryText,
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
