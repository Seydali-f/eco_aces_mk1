import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

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
                InkWell(
                  onTap: () {
                    context.read<RoverState>().toggleAuxSystem('CAMERA');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: roverState.cameraPowerOn ? AppTheme.safeGreen.withOpacity(0.2) : AppTheme.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: roverState.cameraPowerOn ? AppTheme.safeGreen : AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Icon(roverState.cameraPowerOn ? Icons.videocam_off : Icons.videocam, 
                             size: 16, 
                             color: roverState.cameraPowerOn ? AppTheme.dangerRed : AppTheme.safeGreen),
                        const SizedBox(width: 8),
                        Text(roverState.cameraPowerOn ? 'Stop Live' : 'Go Live', 
                             style: TextStyle(
                               color: roverState.cameraPowerOn ? AppTheme.dangerRed : AppTheme.safeGreen, 
                               fontSize: 12,
                               fontWeight: FontWeight.bold,
                             )),
                      ],
                    ),
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
                    const MjpegWebView(streamUrl: 'http://127.0.0.1:5000/video_feed'),
                  
                  // Top overlay info
                  if (roverState.cameraPowerOn)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.safeGreen.withOpacity(0.5)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: AppTheme.safeGreen, size: 12),
                            SizedBox(width: 8),
                            Text('LIVE (AI ASSISTED)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
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

class MjpegWebView extends StatefulWidget {
  final String streamUrl;
  const MjpegWebView({Key? key, required this.streamUrl}) : super(key: key);

  @override
  State<MjpegWebView> createState() => _MjpegWebViewState();
}

class _MjpegWebViewState extends State<MjpegWebView> {
  late final String _viewId;
  late final html.ImageElement _imageElement;

  @override
  void initState() {
    super.initState();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _viewId = 'mjpeg_stream_$timestamp';
    
    _imageElement = html.ImageElement()
      ..src = '${widget.streamUrl}?t=$timestamp'
      ..crossOrigin = 'anonymous'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => _imageElement,
    );
  }

  @override
  void dispose() {
    // Crucial: Clear the src to force the browser to abort the active HTTP MJPEG connection
    _imageElement.src = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
