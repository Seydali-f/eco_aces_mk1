import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rover_state.dart';
import '../theme.dart';
import 'ui/glass_panel.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RoverState>();
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppTheme.panel.withOpacity(0.15),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          // Logo/Title
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 32.0, bottom: 24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.panel,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.infoBlue.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(color: AppTheme.infoBlue.withOpacity(0.2), blurRadius: 10)
                    ]
                  ),
                  child: const Icon(Icons.memory, color: AppTheme.infoBlue, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('ROVER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 1.2)),
                    Text('COMMAND CENTER', style: TextStyle(fontSize: 9, color: AppTheme.infoBlue, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
              ],
            ),
          ),
          
          // Navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(Icons.grid_view_rounded, 'Dashboard', state.currentTab == 0, () => state.changeTab(0)),
                _buildNavItem(Icons.map_outlined, 'Map & People', state.currentTab == 1, () => state.changeTab(1)),
                _buildNavItem(Icons.sensors, 'Sensors', state.currentTab == 2, () => state.changeTab(2)),
                _buildNavItem(Icons.history, 'History', state.currentTab == 3, () => state.changeTab(3)),
                _buildNavItem(Icons.settings_outlined, 'Settings', state.currentTab == 4, () => state.changeTab(4)),
              ],
            ),
          ),
          
          // Bottom Status Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildBottomStatusCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2C3240) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppTheme.border : Colors.transparent),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (isSelected)
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.infoBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(icon, color: isSelected ? AppTheme.infoBlue : AppTheme.secondaryText, size: 20),
                  title: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryText : AppTheme.secondaryText,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  onTap: onTap,
                  dense: true,
                  contentPadding: EdgeInsets.only(left: isSelected ? 12 : 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomStatusCard(BuildContext context) {
    final state = context.watch<RoverState>();
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      glowColor: state.isConnected ? AppTheme.safeGreen : AppTheme.dangerRed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ROVER STATUS', style: TextStyle(fontSize: 11, color: AppTheme.secondaryText, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.circle, color: state.isConnected ? AppTheme.safeGreen : AppTheme.dangerRed, size: 8),
              const SizedBox(width: 8),
              Text(state.isConnected ? 'CONNECTED' : 'DISCONNECTED', style: TextStyle(color: state.isConnected ? AppTheme.safeGreen : AppTheme.dangerRed, fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Battery:', style: TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
              Text('${state.battery}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: state.battery / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00FF7F), Color(0xFF00FFFF)]),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [BoxShadow(color: const Color(0xFF00FF7F).withOpacity(0.5), blurRadius: 8)],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Signal:', style: TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
              Text('Strong', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            alignment: Alignment.center,
            child: const Text('MANUAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primaryText)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.cloud, color: Colors.orangeAccent, size: 18),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('30°C', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  Text('Light rain', style: TextStyle(color: AppTheme.secondaryText, fontSize: 9)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
