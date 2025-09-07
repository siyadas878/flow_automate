// lib/models/workflow_node.dart
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

enum NodeType { condition, action, output }
enum OperationType { equals, notEquals, greaterThan, lessThan, present, notPresent }

class WorkflowNode {
  final String id;
  final Signal<NodeType> type;
  final Signal<Offset> position;
  final Signal<String> title;
  final Signal<String> description;
  final Signal<Map<String, dynamic>> properties;
  final Signal<bool> isSelected;
  
  // Connections
  WorkflowNode? trueConnection;
  WorkflowNode? falseConnection;
  WorkflowNode? nextConnection;

  WorkflowNode({
    required this.id,
    required Offset initialPosition,
    NodeType initialType = NodeType.condition,
    String initialTitle = '',
    String initialDescription = '',
    Map<String, dynamic>? initialProperties,
  }) : type = signal(initialType),
       position = signal(initialPosition),
       title = signal(initialTitle),
       description = signal(initialDescription),
       properties = signal(initialProperties ?? {}),
       isSelected = signal(false);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'type': type.value.name,
      'title': title.value,
      'description': description.value,
      'properties': properties.value,
    };

    if (trueConnection != null) {
      json['true_statement'] = trueConnection!.toJson();
    }
    
    if (falseConnection != null) {
      json['false_statement'] = falseConnection!.toJson();
    }
    
    if (nextConnection != null) {
      json['next'] = nextConnection!.toJson();
    }

    return json;
  }

  static WorkflowNode fromJson(Map<String, dynamic> json, Offset position) {
    final node = WorkflowNode(
      id: json['id'] ?? '',
      initialPosition: position,
      initialType: NodeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NodeType.condition,
      ),
      initialTitle: json['title'] ?? '',
      initialDescription: json['description'] ?? '',
      initialProperties: Map<String, dynamic>.from(json['properties'] ?? {}),
    );

    return node;
  }
}