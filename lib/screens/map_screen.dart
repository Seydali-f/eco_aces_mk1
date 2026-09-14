import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rover_state.dart';
import '../theme.dart';
import '../widgets/ui/glass_panel.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RoverState>();
    
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
                        // Map placeholder background
                        Container(color: Colors.black.withOpacity(0.2)),
                        
                        // Map Content Mock
                        Positioned(
                          left: 100, bottom: 100,
                          child: _buildMapNode(Icons.location_on, 'ENTRANCE', Colors.purpleAccent),
                        ),
                        // Path
                        Positioned(
                          left: 120, bottom: 130,
                          child: CustomPaint(
                            size: const Size(150, 80),
                            painter: PathPainter(),
                          ),
                        ),
                        Positioned(
                          left: 270, bottom: 200,
                          child: _buildMapNode(Icons.navigation, 'ROVER-01', AppTheme.infoBlue, isLarge: true),
                        ),
                        
                        // People dots
                        if (state.peopleDetected > 0) ...[
                          Positioned(left: 350, bottom: 120, child: _buildMapNode(Icons.circle, '03', AppTheme.stopOrange)), // Selected
                          if (state.peopleDetected > 1) Positioned(left: 200, bottom: 200, child: _buildMapNode(Icons.circle, '05', AppTheme.safeGreen)),
                          if (state.peopleDetected > 2) Positioned(left: 180, bottom: 350, child: _buildMapNode(Icons.circle, '04', AppTheme.safeGreen)),
                          if (state.peopleDetected > 3) Positioned(left: 350, bottom: 300, child: _buildMapNode(Icons.circle, '01', AppTheme.safeGreen)),
                          if (state.peopleDetected > 4) Positioned(left: 400, bottom: 420, child: _buildMapNode(Icons.circle, '02', AppTheme.safeGreen)),
                          if (state.peopleDetected > 5) Positioned(left: 500, bottom: 220, child: _buildMapNode(Icons.circle, '06', AppTheme.safeGreen)),
                        ],

                        // Floating map buttons
                        Positioned(
                          top: 16, right: 16,
                          child: Column(
                            children: [
                              _buildMapActionButton('CENTER ON ROVER', Icons.my_location, AppTheme.infoBlue, true),
                              const SizedBox(height: 8),
                              _buildMapActionButton('CENTER ON PERSON', Icons.people, Colors.black, false),
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
                      const Text('ROVER-01', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.infoBlue, fontSize: 14)),
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
                        const Text('PERSON 03', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.stopOrange, fontSize: 14)),
                        const SizedBox(height: 16),
                        _buildInfoRow('Confidence:', '94%'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Coordinates:', 'X: 380m, Y: 520m'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Distance from rover:', '18.4m'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Detection:', '22:35:12'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Status:', 'Detected'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
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
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('0${index + 1}', style: const TextStyle(color: AppTheme.safeGreen, fontWeight: FontWeight.bold)),
                                    const Text('X: 650m, Y: 500m', style: TextStyle(fontSize: 10, color: AppTheme.secondaryText)),
                                    const Text('92%', style: TextStyle(fontSize: 10, color: AppTheme.secondaryText)),
                                    const Text('18.4m', style: TextStyle(fontSize: 10, color: AppTheme.secondaryText)),
                                  ],
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
            color: color,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
          ),
          child: isLarge ? Icon(icon, color: Colors.white, size: 16) : null,
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildMapActionButton(String label, IconData icon, Color bgColor, bool isBlue) {
    return Container(
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 11)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
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
