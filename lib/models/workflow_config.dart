import 'package:flutter/material.dart';

class WorkflowConfig {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final double nodeWidth;
  final double nodeHeight;
  final double gridSize;
  final double connectionStrokeWidth;
  final bool showGrid;
  final bool enableSnapping;
  final double snapDistance;
  final Duration animationDuration;
  final Map<String, dynamic> customProperties;

  const WorkflowConfig({
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.grey,
    this.backgroundColor = Colors.white,
    this.nodeWidth = 200.0,
    this.nodeHeight = 120.0,
    this.gridSize = 50.0,
    this.connectionStrokeWidth = 2.0,
    this.showGrid = true,
    this.enableSnapping = false,
    this.snapDistance = 10.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.customProperties = const {},
  });

  WorkflowConfig copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    double? nodeWidth,
    double? nodeHeight,
    double? gridSize,
    double? connectionStrokeWidth,
    bool? showGrid,
    bool? enableSnapping,
    double? snapDistance,
    Duration? animationDuration,
    Map<String, dynamic>? customProperties,
  }) {
    return WorkflowConfig(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      nodeWidth: nodeWidth ?? this.nodeWidth,
      nodeHeight: nodeHeight ?? this.nodeHeight,
      gridSize: gridSize ?? this.gridSize,
      connectionStrokeWidth: connectionStrokeWidth ?? this.connectionStrokeWidth,
      showGrid: showGrid ?? this.showGrid,
      enableSnapping: enableSnapping ?? this.enableSnapping,
      snapDistance: snapDistance ?? this.snapDistance,
      animationDuration: animationDuration ?? this.animationDuration,
      customProperties: customProperties ?? this.customProperties,
    );
  }

  static const WorkflowConfig defaultConfig = WorkflowConfig();

  static const WorkflowConfig darkTheme = WorkflowConfig(
    primaryColor: Colors.blueAccent,
    secondaryColor: Colors.grey,
    backgroundColor: Color(0xFF2D2D2D),
  );

  static const WorkflowConfig compactTheme = WorkflowConfig(
    nodeWidth: 150.0,
    nodeHeight: 80.0,
    gridSize: 30.0,
  );
}