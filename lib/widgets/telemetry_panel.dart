import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rover_state.dart';
import '../theme.dart';
import 'ui/glass_panel.dart';

class TelemetryPanel extends StatelessWidget {
  const TelemetryPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roverState = context.watch<RoverState>();

    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ROVER TELEMETRY', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryText)),
          const SizedBox(height: 24),
          
          _buildTelemetryRow('Speed', '${roverState.speed.toStringAsFixed(1)} m/s'),
          const SizedBox(height: 12),
          _buildTelemetryRow('Heading', '042°', icon: Icons.navigation),
          const SizedBox(height: 12),
          _buildTelemetryRow('Coordinates', 'X 15.20m, Y 10.80m'),
          
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.qr_code, color: AppTheme.secondaryText, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryRow(String label, String value, {IconData? icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.secondaryText)),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppTheme.secondaryText),
              const SizedBox(width: 4),
            ],
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}
