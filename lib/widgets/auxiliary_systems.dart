import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/rover_state.dart';
import '../theme.dart';
import 'ui/glass_panel.dart';

class AuxiliarySystemsPanel extends StatelessWidget {
  const AuxiliarySystemsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roverState = context.watch<RoverState>();

    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AUXILIARY SYSTEMS', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryText)),
          const SizedBox(height: 16),
          
          _buildToggle(context, 'HEADLIGHT', 'ROVER LIGHT', roverState.headlightOn, Icons.lightbulb_outline),
          _buildToggle(context, 'WARNING_HORN', 'WARNING HORN', roverState.warningHornOn, Icons.volume_up),
          _buildToggle(context, 'CAMERA', 'CAMERA POWER', roverState.cameraPowerOn, Icons.videocam),
        ],
      ),
    );
  }

  Widget _buildToggle(BuildContext context, String key, String label, bool value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.primaryText, fontSize: 12)),
          Switch(
            value: value,
            activeColor: AppTheme.safeGreen,
            onChanged: (val) {
              context.read<RoverState>().toggleAuxSystem(key);
            },
          )
        ],
      ),
    );
  }
}
