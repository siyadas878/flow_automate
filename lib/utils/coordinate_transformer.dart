// lib/utils/coordinate_transformer.dart
import 'package:flutter/material.dart';
import '../models/workflow_node.dart';

class CoordinateTransformer {
  Size canvasSize = const Size(2000, 1500);
  Offset canvasOffset = Offset.zero;
  static const double padding = 200.0;

  void calculateBounds(List<WorkflowNode> nodes) {
    if (nodes.isEmpty) return;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;

    for (final node in nodes) {
      final pos = node.position.value;
      minX = minX < pos.dx ? minX : pos.dx;
      minY = minY < pos.dy ? minY : pos.dy;
      maxX = maxX > pos.dx + 200 ? maxX : pos.dx + 200;
      maxY = maxY > pos.dy + 150 ? maxY : pos.dy + 150;
    }

    canvasSize = Size(
      (maxX - minX) + (padding * 2),
      (maxY - minY) + (padding * 2),
    );

    canvasOffset = Offset(
      -minX + padding,
      -minY + padding,
    );
  }

  Offset nodeToCanvasPosition(Offset nodePosition) {
    return Offset(
      nodePosition.dx + canvasOffset.dx,
      nodePosition.dy + canvasOffset.dy,
    );
  }
}