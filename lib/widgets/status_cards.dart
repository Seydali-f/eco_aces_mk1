import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rover_state.dart';
import '../theme.dart';
import 'ui/glass_panel.dart';

class StatusCardsRow extends StatelessWidget {
  const StatusCardsRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roverState = context.watch<RoverState>();
    
    return Row(
      children: [
        Expanded(child: _buildRoverCard(roverState)),
        const SizedBox(width: 16),
        Expanded(child: _buildPeopleCard(roverState)),
        const SizedBox(width: 16),
        Expanded(child: _buildAlertsCard(roverState)),
        const SizedBox(width: 16),
        Expanded(child: _buildEnvironmentCard(roverState)),
      ],
    );
  }

  Widget _buildRoverCard(RoverState state) {
    return GlassPanel(
      glowColor: AppTheme.infoBlue,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Text('ROVER', style: TextStyle(fontSize: 11, color: AppTheme.secondaryText, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
              Icon(Icons.precision_manufacturing, color: AppTheme.secondaryText, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(state.isConnected ? 'Connected' : 'Disconnected', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.infoBlue)),
          const SizedBox(height: 4),
          const Text('Manual Control', style: TextStyle(fontSize: 12, color: AppTheme.safeGreen)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Battery: ${state.battery}%', style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12), overflow: TextOverflow.ellipsis),
              ),
              const Icon(Icons.battery_full, color: AppTheme.safeGreen, size: 20),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPeopleCard(RoverState state) {
    return _BaseStatusCard(
      title: 'PEOPLE DETECTED',
      value: state.peopleDetected.toString().padLeft(2, '0'),
      icon: Icons.person_outline,
      valueColor: AppTheme.infoBlue,
      bottomContent: const Text('+2 in last minute ↗', style: TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
    );
  }

  Widget _buildAlertsCard(RoverState state) {
    final alertCount = state.activeAlertsCount;
    return _BaseStatusCard(
      title: 'ACTIVE ALERTS',
      value: alertCount.toString().padLeft(2, '0'),
      icon: Icons.warning_amber_rounded,
      iconColor: AppTheme.dangerRed,
      valueColor: AppTheme.dangerRed,
      bottomContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('1 Critical', style: TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
          Text('2 Warning', style: TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
        ],
      ),
    );
  }

  Widget _buildEnvironmentCard(RoverState state) {
    bool isDanger = state.ch4Level > 5.0 || state.temperature > 40.0;
    return _BaseStatusCard(
      title: 'ENVIRONMENT',
      value: isDanger ? 'Danger' : 'Safe',
      icon: isDanger ? Icons.warning_amber_rounded : Icons.shield_outlined,
      iconColor: isDanger ? AppTheme.dangerRed : AppTheme.safeGreen,
      valueColor: isDanger ? AppTheme.dangerRed : AppTheme.safeGreen,
      bottomContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gas : ${state.ch4Level.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
          Text('Temp: ${state.temperature.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
        ],
      ),
    );
  }
}

class _BaseStatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? valueColor;
  final Widget bottomContent;

  const _BaseStatusCard({
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.valueColor,
    required this.bottomContent,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.secondaryText, fontWeight: FontWeight.bold, letterSpacing: 0.5), overflow: TextOverflow.ellipsis),
              ),
              Icon(icon, color: iconColor ?? AppTheme.infoBlue, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: valueColor ?? AppTheme.primaryText)),
          const SizedBox(height: 16),
          bottomContent,
        ],
      ),
    );
  }
}
