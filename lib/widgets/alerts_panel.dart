import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rover_state.dart';
import '../theme.dart';
import 'package:intl/intl.dart';

import 'ui/glass_panel.dart';

class AlertsPanel extends StatelessWidget {
  const AlertsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roverState = context.watch<RoverState>();
    final alerts = roverState.alerts;

    return GlassPanel(
      padding: const EdgeInsets.all(16),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SAFETY ALERTS', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: roverState.activeAlertsCount > 0 ? AppTheme.dangerRed : AppTheme.safeGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${roverState.activeAlertsCount} ACTIVE',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: alerts.isEmpty
                ? const Center(child: Text('NO ALERTS', style: TextStyle(color: AppTheme.secondaryText)))
                : ListView.separated(
                    itemCount: alerts.length,
                    separatorBuilder: (context, index) => const Divider(color: AppTheme.border),
                    itemBuilder: (context, index) {
                      final alert = alerts[index];
                      return _buildAlertItem(alert);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(AlertEntry alert) {
    final isCritical = alert.level == 'CRITICAL';
    final color = isCritical ? AppTheme.dangerRed : AppTheme.stopOrange;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(alert.level, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
              Text(
                DateFormat('HH:mm:ss').format(alert.time),
                style: const TextStyle(color: AppTheme.secondaryText, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(alert.message, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
