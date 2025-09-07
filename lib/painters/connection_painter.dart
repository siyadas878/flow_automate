import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/workflow_connection.dart';
import '../models/workflow_node.dart';
import '../utils/coordinate_transformer.dart';

class ConnectionPainter extends CustomPainter {
  final List<WorkflowConnection> connections;
  final CoordinateTransformer transformer;
  final bool isCreatingConnection;
  final WorkflowNode? connectionStartNode;
  final Offset? connectionEndPoint;
  final String? connectionType;

  ConnectionPainter({
    required this.connections,
    required this.transformer,
    this.isCreatingConnection = false,
    this.connectionStartNode,
    this.connectionEndPoint,
    this.connectionType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw existing connections
    for (final connection in connections) {
      _drawConnection(
        canvas,
        connection.source,
        connection.target,
        connection.type,
      );
    }

    // Draw connection being created
    if (isCreatingConnection &&
        connectionStartNode != null &&
        connectionEndPoint != null) {
      _drawTemporaryConnection(
        canvas,
        connectionStartNode!,
        connectionEndPoint!,
        connectionType ?? 'next',
      );
    }
  }

  void _drawConnection(
    Canvas canvas,
    WorkflowNode source,
    WorkflowNode target,
    String connectionType,
  ) {
    final sourcePos = transformer.nodeToCanvasPosition(source.position.value);
    final targetPos = transformer.nodeToCanvasPosition(target.position.value);

    final startPoint = Offset(
      sourcePos.dx + 100, // Center of node width (200/2)
      sourcePos.dy + 60,  // Center of node height (120/2)
    );

    final endPoint = Offset(
      targetPos.dx + 100,
      targetPos.dy + 60,
    );

    final color = _getConnectionColor(connectionType);
    _drawCurvedLine(canvas, startPoint, endPoint, color, connectionType);
  }

  void _drawTemporaryConnection(
    Canvas canvas,
    WorkflowNode source,
    Offset endPoint,
    String connectionType,
  ) {
    final sourcePos = transformer.nodeToCanvasPosition(source.position.value);
    final startPoint = Offset(
      sourcePos.dx + 100,
      sourcePos.dy + 60,
    );

    final color = _getConnectionColor(connectionType).withOpacity(0.7);
    _drawCurvedLine(canvas, startPoint, endPoint, color, connectionType);
  }

  void _drawCurvedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    String connectionType,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Create curved path
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Calculate control points for smooth curve
    final distance = (end - start).distance;
    final controlOffset = math.min(distance * 0.5, 100.0);

    final controlPoint1 = Offset(start.dx + controlOffset, start.dy);
    final controlPoint2 = Offset(end.dx - controlOffset, end.dy);

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      end.dx,
      end.dy,
    );

    canvas.drawPath(path, paint);

    // Draw arrow at the end
    _drawArrow(canvas, end, _calculateArrowAngle(controlPoint2, end), color);

    // Draw connection label
    _drawConnectionLabel(
      canvas,
      _calculateMidPoint(start, end),
      connectionType,
      color,
    );
  }

  void _drawArrow(Canvas canvas, Offset tip, double angle, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const arrowSize = 12.0;
    const arrowAngle = math.pi / 6; // 30 degrees

    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(
      tip.dx - arrowSize * math.cos(angle - arrowAngle),
      tip.dy - arrowSize * math.sin(angle - arrowAngle),
    );
    path.lineTo(
      tip.dx - arrowSize * math.cos(angle + arrowAngle),
      tip.dy - arrowSize * math.sin(angle + arrowAngle),
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawConnectionLabel(
    Canvas canvas,
    Offset position,
    String connectionType,
    Color color,
  ) {
    final labelText = _getConnectionLabel(connectionType);
    if (labelText.isEmpty) return;

    final textPainter = TextPainter(
      text: TextSpan(
        text: labelText,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Draw background
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: position,
        width: textPainter.width + 8,
        height: textPainter.height + 4,
      ),
      const Radius.circular(4),
    );

    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(backgroundRect, backgroundPaint);
    canvas.drawRRect(backgroundRect, borderPaint);

    // Draw text
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  Color _getConnectionColor(String connectionType) {
    switch (connectionType.toLowerCase()) {
      case 'true':
        return Colors.green;
      case 'false':
        return Colors.red;
      case 'next':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getConnectionLabel(String connectionType) {
    switch (connectionType.toLowerCase()) {
      case 'true':
        return 'TRUE';
      case 'false':
        return 'FALSE';
      case 'next':
        return 'NEXT';
      default:
        return connectionType.toUpperCase();
    }
  }

  double _calculateArrowAngle(Offset from, Offset to) {
    return math.atan2(to.dy - from.dy, to.dx - from.dx);
  }

  Offset _calculateMidPoint(Offset start, Offset end) {
    return Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for smooth animations
  }
}