import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rover_state.dart';
import '../theme.dart';
import '../widgets/ui/glass_panel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  final TransformationController _transformationController = TransformationController();
  int _selectedPersonIndex = -1;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    // Initial center on rover
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerOnPosition(1170.0, 850.0);
    });
  }

  void _centerOnPosition(double x, double y) {
    if (!mounted) return;
    
    // Assuming viewport is roughly 800x600 for the map
    // We want the coordinate (x,y) to be in the center of the viewport
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    double vpWidth = 800.0;
    double vpHeight = 600.0;
    if (renderBox != null) {
      // Very rough estimate of map panel size
      vpWidth = renderBox.size.width * 0.6;
      vpHeight = renderBox.size.height;
    }

    final targetX = -x + (vpWidth / 2);
    final targetY = -y + (vpHeight / 2);
    
    _transformationController.value = Matrix4.identity()
      ..translate(targetX, targetY);
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RoverState>();
    
    // Auto-select first person if available and none selected
    if (state.peopleDetected > 0 && _selectedPersonIndex == -1) {
      _selectedPersonIndex = 0;
    } else if (state.peopleDetected == 0) {
      _selectedPersonIndex = -1;
    }
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Map Panel
          Expanded(
            flex: 5,
            child: GlassPanel(
              child: Column(
                children: [
                  // Map Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('UNDERGROUND TUNNEL MAP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.secondaryText)),
                        Row(
                          children: [
                            _buildLegendItem('Entrance', Colors.purpleAccent),
                            _buildLegendItem('Rover', AppTheme.infoBlue),
                            _buildLegendItem('Detected Person', AppTheme.safeGreen),
                            _buildLegendItem('Selected Person', AppTheme.stopOrange),
                          ],
                        )
                      ],
                    ),
                  ),
                  const Divider(color: AppTheme.border, height: 1),
                  // Map Body
                  Expanded(
                    child: Stack(
                      children: [
                        // Interactive Map Area
                        InteractiveViewer(
                          transformationController: _transformationController,
                          boundaryMargin: const EdgeInsets.all(2000),
                          minScale: 0.1,
                          maxScale: 5.0,
                          constrained: false,
                          trackpadScrollCausesScale: true,
                          child: Container(
                            width: 2000,
                            height: 2000,
                            color: Colors.transparent, // Capture pan events
                            child: Stack(
                              children: [
                                // Tech Grid background
                                CustomPaint(
                                  size: const Size(2000, 2000),
                                  painter: GridPainter(),
                                ),
                                
                                // Map Content Mock
                                Positioned(
                                  left: 1000, top: 1000,
                                  child: _buildMapNode(Icons.location_on, 'ENTRANCE', Colors.purpleAccent),
                                ),
                                // Path
                                Positioned(
                                  left: 1020, top: 920,
                                  child: CustomPaint(
                                    size: const Size(150, 80),
                                    painter: PathPainter(),
                                  ),
                                ),
                                Positioned(
                                  left: 1170, top: 850,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Radar Sweeper centered on Rover
                                      AnimatedBuilder(
                                        animation: _radarController,
                                        builder: (context, child) {
                                          return CustomPaint(
                                            size: const Size(400, 400),
                                            painter: RadarPainter(_radarController.value),
                                          );
                                        }
                                      ),
                                      _buildMapNode(Icons.navigation, 'ROVER-01', AppTheme.infoBlue, isLarge: true),
                                    ],
                                  ),
                                ),
                                
                                // People dots
                                if (state.peopleDetected > 0) ...List.generate(state.peopleDetected, (index) {
                                  // Mock positions relative to rover
                                  final offsets = [
                                    const Offset(1250, 930),
                                    const Offset(1100, 850),
                                    const Offset(1080, 700),
                                    const Offset(1250, 750),
                                    const Offset(1300, 630),
                                    const Offset(1400, 830),
                                  ];
                                  final pos = index < offsets.length ? offsets[index] : offsets[0];
                                  final isSelected = index == _selectedPersonIndex;
                                  return Positioned(
                                    left: pos.dx,
                                    top: pos.dy,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedPersonIndex = index;
                                        });
                                      },
                                      child: _buildMapNode(
                                        Icons.circle,
                                        '0${index + 1}',
                                        isSelected ? AppTheme.stopOrange : AppTheme.safeGreen,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        
                        // Floating map buttons
                        Positioned(
                          top: 16, right: 16,
                          child: Column(
                            children: [
                              _buildMapActionButton('CENTER ON ROVER', Icons.my_location, AppTheme.infoBlue, true, () {
                                _centerOnPosition(1170.0, 850.0);
                              }),
                              const SizedBox(height: 8),
                              _buildMapActionButton('CENTER ON PERSON', Icons.people, Colors.black, false, () {
                                if (_selectedPersonIndex != -1) {
                                  final offsets = [
                                    const Offset(1250, 930),
                                    const Offset(1100, 850),
                                    const Offset(1080, 700),
                                    const Offset(1250, 750),
                                    const Offset(1300, 630),
                                    const Offset(1400, 830),
                                  ];
                                  final pos = _selectedPersonIndex < offsets.length ? offsets[_selectedPersonIndex] : offsets[0];
                                  _centerOnPosition(pos.dx, pos.dy);
                                }
                              }),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          
          // Right: Info Panels
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Rover Info
                GlassPanel(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ROVER-01', style: AppTheme.hudFont),
                      const SizedBox(height: 16),
                      _buildInfoRow('Coordinates:', 'X: 15.20m, Y: 10.80m'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Heading:', '042°'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Status:', 'Manual Control'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Person Info
                if (_selectedPersonIndex != -1) ...[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.stopOrange.withOpacity(0.5)),
                    ),
                    child: GlassPanel(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PERSON 0${_selectedPersonIndex + 1}', style: AppTheme.hudFont.copyWith(color: AppTheme.stopOrange)),
                          const SizedBox(height: 16),
                          _buildInfoRow('Confidence:', '${90 + (_selectedPersonIndex * 2)}%'),
                          const SizedBox(height: 8),
                          _buildInfoRow('Coordinates:', 'X: ${300 + (_selectedPersonIndex * 15)}m, Y: ${500 - (_selectedPersonIndex * 20)}m'),
                          const SizedBox(height: 8),
                          _buildInfoRow('Distance from rover:', '${18.4 + (_selectedPersonIndex * 2.1)}m'),
                          const SizedBox(height: 8),
                          _buildInfoRow('Detection:', '22:35:12'),
                          const SizedBox(height: 8),
                          _buildInfoRow('Status:', 'Detected'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // People List
                Expanded(
                  child: GlassPanel(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PEOPLE LIST', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryText, fontSize: 12)),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.peopleDetected,
                            itemBuilder: (context, index) {
                              final isSelected = index == _selectedPersonIndex;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedPersonIndex = index;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.infoBlue.withOpacity(0.2) : Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? AppTheme.infoBlue : AppTheme.infoBlue.withOpacity(0.1)
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('0${index + 1}', style: TextStyle(color: isSelected ? Colors.white : AppTheme.safeGreen, fontWeight: FontWeight.bold)),
                                      Text('X: ${300 + (index * 15)}m', style: TextStyle(fontFamily: 'Share Tech Mono', fontSize: 11, color: isSelected ? Colors.white : AppTheme.secondaryText)),
                                      Text('${90 + (index * 2)}%', style: TextStyle(fontFamily: 'Share Tech Mono', fontSize: 11, color: isSelected ? Colors.white : AppTheme.secondaryText)),
                                      Text('${18.4 + (index * 2.1)}m', style: TextStyle(fontFamily: 'Share Tech Mono', fontSize: 11, color: isSelected ? Colors.white : AppTheme.secondaryText)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.secondaryText)),
        ],
      ),
    );
  }

  Widget _buildMapNode(IconData icon, String label, Color color, {bool isLarge = false}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isLarge ? 6 : 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
            boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
          ),
          child: isLarge ? Icon(icon, color: color, size: 16) : null,
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.techFont.copyWith(fontSize: 10, color: color)),
      ],
    );
  }

  Widget _buildMapActionButton(String label, IconData icon, Color bgColor, bool isBlue, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 160,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isBlue ? AppTheme.infoBlue : Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 11)),
        Text(value, style: AppTheme.techFont.copyWith(color: Colors.white, fontSize: 13)),
      ],
    );
  }
}

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.infoBlue.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.2, size.height * 0.1);
    path.lineTo(size.width * 0.5, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.1);
    path.lineTo(size.width, 0);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.infoBlue.withOpacity(0.05)
      ..strokeWidth = 1;
    
    const double spacing = 40.0;
    
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RadarPainter extends CustomPainter {
  final double sweep;
  RadarPainter(this.sweep);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw radar rings
    final ringPaint = Paint()
      ..color = AppTheme.infoBlue.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawCircle(center, radius * 0.66, ringPaint);
    canvas.drawCircle(center, radius * 0.33, ringPaint);

    // Draw sweep
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: math.pi / 2,
        colors: [
          AppTheme.infoBlue.withOpacity(0.0),
          AppTheme.infoBlue.withOpacity(0.5),
        ],
        transform: GradientRotation(sweep * math.pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      sweep * math.pi * 2,
      math.pi / 2,
      true,
      sweepPaint
    );
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) => oldDelegate.sweep != sweep;
}
