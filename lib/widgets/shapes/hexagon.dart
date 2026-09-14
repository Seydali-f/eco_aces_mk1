import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexagonWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Widget? child;
  final bool hasGlow;
  final Color? glowColor;
  final bool isPressed;

  const HexagonWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.color,
    this.child,
    this.hasGlow = false,
    this.glowColor,
    this.isPressed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 3D effect values
    final double elevation = isPressed ? 2.0 : 8.0;
    
    return Container(
      width: width,
      height: height + 8, // extra height for the 3D shadow
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Base (Shadow/Bottom edge of the 3D button)
          Positioned(
            top: elevation,
            child: ClipPath(
              clipper: RoundedHexagonClipper(),
              child: Container(
                width: width,
                height: height,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          
          // 3D Side/Bevel
          Positioned(
            top: elevation,
            child: ClipPath(
              clipper: RoundedHexagonClipper(),
              child: Container(
                width: width,
                height: height,
                color: _darken(color, 0.3),
              ),
            ),
          ),

          // Top Face
          Positioned(
            top: isPressed ? elevation : 0,
            child: ClipPath(
              clipper: RoundedHexagonClipper(),
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _lighten(color, 0.2),
                      color,
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color _lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}

class RoundedHexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double cornerRadius = w * 0.1; // Rounded edges

    // Hexagon vertices (pointy top)
    final points = [
      Offset(w * 0.5, 0),
      Offset(w, h * 0.25),
      Offset(w, h * 0.75),
      Offset(w * 0.5, h),
      Offset(0, h * 0.75),
      Offset(0, h * 0.25),
    ];

    path.moveTo(w * 0.5, 0);

    for (int i = 0; i < 6; i++) {
      int next = (i + 1) % 6;
      int prev = (i - 1 < 0) ? 5 : i - 1;

      // Current vertex
      Offset p = points[i];
      // Next vertex
      Offset n = points[next];
      // Previous vertex
      Offset prevP = points[prev];

      // Vector from p to prevP
      double dx1 = prevP.dx - p.dx;
      double dy1 = prevP.dy - p.dy;
      double len1 = math.sqrt(dx1 * dx1 + dy1 * dy1);
      
      // Vector from p to n
      double dx2 = n.dx - p.dx;
      double dy2 = n.dy - p.dy;
      double len2 = math.sqrt(dx2 * dx2 + dy2 * dy2);

      // Unit vectors
      dx1 /= len1; dy1 /= len1;
      dx2 /= len2; dy2 /= len2;

      // Start of curve (radius distance towards prevP)
      double r = cornerRadius;
      Offset curveStart = Offset(p.dx + dx1 * r, p.dy + dy1 * r);
      
      // End of curve (radius distance towards n)
      Offset curveEnd = Offset(p.dx + dx2 * r, p.dy + dy2 * r);

      if (i == 0) {
        path.moveTo(curveStart.dx, curveStart.dy);
      } else {
        path.lineTo(curveStart.dx, curveStart.dy);
      }
      
      // Quadratic bezier to the end of the curve using p as the control point
      path.quadraticBezierTo(p.dx, p.dy, curveEnd.dx, curveEnd.dy);
    }
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
