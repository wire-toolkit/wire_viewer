import 'dart:math';
import 'dart:ui' as ui;

import 'package:bezier/bezier.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as math;
import 'package:wire_viewer/model/vos/WireContextVO.dart';
import 'package:wire_viewer/utils/PositionUtils.dart';

class WiresPainterWidget extends StatelessWidget {
  final WireContextVO wireContextVO;
  const WiresPainterWidget(this.wireContextVO, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: ui.window.physicalSize,
        painter: PathPainter(wireContextVO),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  final WireContextVO wireContextVO;

  PathPainter(this.wireContextVO):super(repaint: wireContextVO.position) {}

  @override
  void paint(Canvas canvas, Size size) {
    if (wireContextVO.connections == null) return;

    Point<double> start = wireContextVO.position.value;
    List<CubicBezier> curves = wireContextVO.connections!.map((WireContextVO c) {
      final end = c.block;
      final x = end.left, y = end.top;
      final double startX = x < start.x
          ? PositionUtils.snapToGrid(wireContextVO.left)
          : PositionUtils.snapToGrid(wireContextVO.right);
      return CubicBezier([
        math.Vector2(startX, start.y),
        math.Vector2((startX + x) / 2, start.y),
        math.Vector2((startX + x) / 2, y),
        math.Vector2(x, y),
      ]);
    }).toList();

    curves.forEach((curve) {
      final points = curve.points;
      canvas.drawPoints(ui.PointMode.points,
        points
          .where((p) => [0, 3].contains(points.indexOf(p)))
          .map((p) => Offset(p.x, p.y)).toList(),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
      );
      final path = Path()
        ..moveTo(points.first.x, points.first.y)
        ..cubicTo(points[1].x, points[1].y, points[2].x, points[2].y, points.last.x, points.last.y);
      canvas.drawPath(path,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
      );
    });
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}
