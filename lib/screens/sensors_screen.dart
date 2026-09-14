import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rover_state.dart';
import '../theme.dart';
import '../widgets/ui/glass_panel.dart';

class SensorsScreen extends StatelessWidget {
  const SensorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RoverState>();
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Top Row: 3 Cards
          Row(
            children: [
              Expanded(child: _buildValueCard('GAS LEVEL', '${state.ch4Level.toStringAsFixed(1)}', state.ch4Level > 2.0)),
              const SizedBox(width: 24),
              Expanded(child: _buildValueCard('TEMPERATURE', '${state.temperature.toStringAsFixed(1)}°C', state.temperature > 50)),
              const SizedBox(width: 24),
              Expanded(child: _buildValueCard('HUMIDITY', '${state.humidity.toStringAsFixed(1)}%', false)),
            ],
          ),
          const SizedBox(height: 24),
          
          // Bottom Row
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Col: Charts
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(child: _buildChartPanel('TEMPERATURE - Last 60 seconds', AppTheme.safeGreen)),
                      const SizedBox(height: 24),
                      Expanded(child: _buildChartPanel('GAS - Last 60 seconds', AppTheme.infoBlue)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right Col: Health
                Expanded(
                  flex: 1,
                  child: GlassPanel(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SENSOR HEALTH', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryText)),
                        const SizedBox(height: 24),
                        _buildHealthRow('Connection', state.isConnected ? 'Stable' : 'Offline', state.isConnected ? AppTheme.safeGreen : AppTheme.dangerRed),
                        const SizedBox(height: 16),
                        _buildHealthRow('Last Update', state.isConnected ? '0 sec ago' : '--', Colors.white),
                        const SizedBox(height: 16),
                        _buildHealthRow('Sampling', '0.5 Hz', Colors.white),
                        const SizedBox(height: 16),
                        _buildHealthRow('Signal Quality', state.isConnected ? '98%' : '0%', AppTheme.safeGreen),
                        const SizedBox(height: 16),
                        _buildHealthRow('Sensor Battery', '${state.battery}%', AppTheme.safeGreen),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard(String title, String value, bool isWarning) {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryText, fontSize: 12)),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: isWarning ? AppTheme.dangerRed : AppTheme.safeGreen)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isWarning ? AppTheme.dangerRed : AppTheme.safeGreen).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: (isWarning ? AppTheme.dangerRed : AppTheme.safeGreen).withOpacity(0.3)),
            ),
            child: Text(isWarning ? 'WARNING' : 'NORMAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isWarning ? AppTheme.dangerRed : AppTheme.safeGreen)),
          )
        ],
      ),
    );
  }

  Widget _buildHealthRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildChartPanel(String title, Color lineColor) {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryText, fontSize: 12)),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  const Positioned(
                    bottom: 0, left: 0,
                    child: Text('0', style: TextStyle(color: AppTheme.secondaryText, fontSize: 10)),
                  ),
                  Positioned(
                    bottom: 0, left: 20, right: 0,
                    child: Container(
                      height: 2,
                      color: lineColor,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
