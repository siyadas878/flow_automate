// lib/models/workflow_connection.dart
import 'workflow_node.dart';

class WorkflowConnection {
  final WorkflowNode source;
  final WorkflowNode target;
  final String type; // 'true', 'false', 'next'

  WorkflowConnection({
    required this.source,
    required this.target,
    required this.type,
  });
}