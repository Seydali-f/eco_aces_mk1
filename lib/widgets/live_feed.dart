import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rover_state.dart';
import '../theme.dart';
import 'ui/glass_panel.dart';

class LiveFeedPanel extends StatelessWidget {
  const LiveFeedPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roverState = context.watch<RoverState>();

    return GlassPanel(
      glowColor: Colors.black, // Soft ambient glow for the main screen
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('LIVE STREAM (AI BACKEND)', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.videocam, size: 16, color: AppTheme.safeGreen),
                      SizedBox(width: 8),
                      Text('Go Live', style: TextStyle(color: AppTheme.safeGreen, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          // Video Area
          AspectRatio(
            aspectRatio: 16 / 11,
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1115),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!roverState.cameraPowerOn)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videocam_off, size: 80, color: AppTheme.dangerRed),
                        const SizedBox(height: 16),
                        const Text('CAMERA POWER OFF', style: TextStyle(color: AppTheme.dangerRed, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    )
                  else
                    // Actual Stream from Python backend
                    Image.network(
                      'http://127.0.0.1:5000/video_feed',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 80, color: AppTheme.stopOrange),
                            const SizedBox(height: 16),
                            const Text('AI BACKEND OFFLINE', style: TextStyle(color: AppTheme.stopOrange, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 8),
                            const Text('Ensure Python Flask server is running on port 5000', style: TextStyle(color: AppTheme.secondaryText, fontSize: 11)),
                          ],
                        );
                      },
                    ),
                  
                  // Top overlay info
                  if (roverState.cameraPowerOn)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                        child: const Text('REC • YOLOv8', style: TextStyle(color: AppTheme.safeGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
