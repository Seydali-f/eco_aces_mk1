import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/header.dart';
import '../widgets/status_cards.dart';
import '../widgets/live_feed.dart';
import '../widgets/drive_control.dart';
import '../widgets/telemetry_panel.dart';
import '../widgets/thermal_feed.dart';
import '../widgets/command_log.dart';
import '../widgets/auxiliary_systems.dart';
import '../theme.dart';
import 'package:provider/provider.dart';
import '../providers/rover_state.dart';
import 'map_screen.dart';
import 'sensors_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Color(0xFF1E2336), // Deep blue-charcoal
              Color(0xFF0F1116), // Very dark space
            ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Sidebar
          const Sidebar(),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                const Header(),
                
                // Dashboard Content
                Expanded(
                  child: Consumer<RoverState>(
                    builder: (context, state, child) {
                      Widget activePage;
                      switch (state.currentTab) {
                        case 1:
                          activePage = const MapScreen();
                          break;
                        case 2:
                          activePage = const SensorsScreen();
                          break;
                        case 3:
                          activePage = const HistoryScreen();
                          break;
                        case 4:
                          activePage = const SettingsScreen();
                          break;
                        case 0:
                        default:
                          activePage = SingleChildScrollView(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Status Cards
                                const StatusCardsRow(),
                                const SizedBox(height: 24),
                        
                        // 3-Column Layout
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 1000) {
                              return Column(
                                children: [
                                  // Top Row: Cameras
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: const LiveFeedPanel()),
                                      const SizedBox(width: 24),
                                      Expanded(child: const ThermalFeedPanel()),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Bottom Row: Controls & Logs
                                  IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(flex: 3, child: const DriveControlPanel()),
                                        const SizedBox(width: 24),
                                        Expanded(flex: 5, child: const CommandLogPanel()),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  const LiveFeedPanel(),
                                  const SizedBox(height: 24),
                                  const ThermalFeedPanel(),
                                  const SizedBox(height: 24),
                                  IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: const DriveControlPanel(),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          flex: 5,
                                          child: const CommandLogPanel(),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                      } // end switch
                      return activePage;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
