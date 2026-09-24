import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rover_state.dart';
import '../theme.dart';
import '../widgets/ui/glass_panel.dart';
import '../widgets/ui/line_chart.dart';

class SensorsScreen extends StatelessWidget {
  const SensorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RoverState>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildValueCard('GAS LEVEL', '${state.ch4Level.toStringAsFixed(1)}', state.ch4Level > 2.0, Icons.cloud_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _buildValueCard('TEMPERATURE', '${state.temperature.toStringAsFixed(1)}°C', state.temperature > 50, Icons.thermostat_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _buildValueCard('HUMIDITY', '${state.humidity.toStringAsFixed(1)}%', false, Icons.water_drop_outlined)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Bottom Row (now has a massive fixed height so graphs are huge)
          SizedBox(
            height: 600,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Col: Charts
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Expanded(child: _buildChartPanel('TEMPERATURE - Last 60 seconds', AppTheme.safeGreen, state.tempHistory, 80.0)),
                      const SizedBox(height: 12),
                      Expanded(child: _buildChartPanel('GAS - Last 60 seconds', AppTheme.infoBlue, state.gasHistory, 10.0)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Right Col: Health
                Expanded(
                  flex: 1,
                  child: GlassPanel(
                    width: double.infinity,
                    height: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SENSOR HEALTH', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryText)),
                        const SizedBox(height: 24),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildHealthRow('Connection', state.isConnected ? 'Stable' : 'Offline', state.isConnected ? AppTheme.safeGreen : AppTheme.dangerRed),
                              _buildHealthRow('Last Update', state.isConnected ? '0 sec ago' : '--', Colors.white),
                              _buildHealthRow('Sampling', '0.5 Hz', Colors.white),
                              _buildHealthRow('Signal Quality', state.isConnected ? '98%' : '0%', AppTheme.safeGreen),
                              _buildHealthRow('Sensor Battery', '${state.battery}%', AppTheme.safeGreen),
                            ],
                          ),
                        ),
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

  Widget _buildValueCard(String title, String value, bool isWarning, IconData icon) {
    return GlassPanel(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Background Icon
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              icon,
              size: 140,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryText, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(value, style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: isWarning ? AppTheme.dangerRed : AppTheme.safeGreen)),
                  const SizedBox(height: 8),
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
            ),
          ),
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

  Widget _buildChartPanel(String title, Color lineColor, List<double> data, double maxY) {
    return GlassPanel(
      width: double.infinity,
      height: double.infinity,
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
                  Positioned(
                    bottom: 0, left: 0,
                    child: Text('0', style: TextStyle(color: AppTheme.secondaryText, fontSize: 10)),
                  ),
                  Positioned(
                    top: 0, left: 0,
                    child: Text(maxY.toStringAsFixed(0), style: TextStyle(color: AppTheme.secondaryText, fontSize: 10)),
                  ),
                  Positioned(
                    top: 0, bottom: 0, left: 24, right: 0,
                    child: LineChart(
                      data: data,
                      color: lineColor,
                      maxY: maxY,
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
