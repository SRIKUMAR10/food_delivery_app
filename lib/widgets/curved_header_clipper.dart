import 'package:flutter/material.dart';

class InwardCurvedHeaderClipper extends CustomClipper<Path> {
  // You can adjust this value to change how high the curve goes up on the right side
  final double curveHeight;

  InwardCurvedHeaderClipper({this.curveHeight = 70.0});

  @override
  Path getClip(Size size) {
    Path path = Path();
    
    // 1. Start at top-left
    path.moveTo(0, 0);
    
    // 2. Line to bottom-left
    path.lineTo(0, size.height);
    
    // The point where the curve starts on the bottom edge (roughly 40% of the width)
    double curveStartX = size.width * 0.4;
    
    // 3. Line horizontally to the start of the curve
    path.lineTo(curveStartX, size.height);
    
    // 4. Smooth S-Curve (Cubic Bezier) swooping UP to the right edge
    path.cubicTo(
      size.width * 0.75, size.height,                 // Control point 1: keeps the curve horizontal initially
      size.width * 0.7, size.height - curveHeight,    // Control point 2: pulls the curve to flatten out at the top
      size.width, size.height - curveHeight,          // End point: on the right edge, higher up
    );
    
    // 5. Line to top-right
    path.lineTo(size.width, 0);
    
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(covariant InwardCurvedHeaderClipper oldClipper) {
    return oldClipper.curveHeight != curveHeight;
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    
    // Start from top-left and go down the left side
    path.lineTo(0, size.height * 0.55);

    // Create the smooth S-curve wave to the bottom-right corner
    path.cubicTo(
      size.width * 0.35, // Control point 1 X
      size.height * 0.85, // Control point 1 Y
      size.width * 0.65, // Control point 2 X
      size.height * 0.50, // Control point 2 Y
      size.width,         // End point X
      size.height * 0.95, // End point Y
    );

    // Complete the path along the right side back to the top
    path.lineTo(size.width, 0);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
