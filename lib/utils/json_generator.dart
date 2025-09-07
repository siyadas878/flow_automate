import 'dart:convert';
import 'dart:ui' show Offset;
import '../models/workflow_node.dart';

class JsonGenerator {
  static String generateWorkflowJson(WorkflowNode rootNode, {bool pretty = true}) {
    final jsonData = _nodeToJson(rootNode);
    
    if (pretty) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonData);
    } else {
      return jsonEncode(jsonData);
    }
  }

  static Map<String, dynamic> _nodeToJson(WorkflowNode node) {
    final json = <String, dynamic>{
      'id': node.id,
      'type': node.type.value.name,
      'title': node.title.value,
      'description': node.description.value,
      'properties': Map<String, dynamic>.from(node.properties.value),
      'position': {
        'x': node.position.value.dx,
        'y': node.position.value.dy,
      },
    };

    // Add connections based on node type
    if (node.trueConnection != null) {
      json['true_statement'] = _nodeToJson(node.trueConnection!);
    }

    if (node.falseConnection != null) {
      json['false_statement'] = _nodeToJson(node.falseConnection!);
    }

    if (node.nextConnection != null) {
      json['next'] = _nodeToJson(node.nextConnection!);
    }

    return json;
  }

  static WorkflowNode? parseWorkflowJson(String jsonString) {
    try {
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return _jsonToNode(jsonData);
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }
  }

  static WorkflowNode _jsonToNode(Map<String, dynamic> json) {
    final nodeType = NodeType.values.firstWhere(
      (type) => type.name == json['type'],
      orElse: () => NodeType.condition,
    );

    final position = json['position'] != null
        ? Offset(
            (json['position']['x'] as num).toDouble(),
            (json['position']['y'] as num).toDouble(),
          )
        : Offset.zero;

    final node = WorkflowNode(
      id: json['id'] ?? '',
      initialPosition: position,
      initialType: nodeType,
      initialTitle: json['title'] ?? '',
      initialDescription: json['description'] ?? '',
      initialProperties: Map<String, dynamic>.from(json['properties'] ?? {}),
    );

    // Parse connections
    if (json['true_statement'] != null) {
      node.trueConnection = _jsonToNode(json['true_statement']);
    }

    if (json['false_statement'] != null) {
      node.falseConnection = _jsonToNode(json['false_statement']);
    }

    if (json['next'] != null) {
      node.nextConnection = _jsonToNode(json['next']);
    }

    return node;
  }

  static List<ValidationError> validateWorkflow(WorkflowNode rootNode) {
    final errors = <ValidationError>[];
    final visitedNodes = <String>{};

    _validateNode(rootNode, errors, visitedNodes);

    return errors;
  }

  static void _validateNode(
    WorkflowNode node,
    List<ValidationError> errors,
    Set<String> visitedNodes,
  ) {
    // Check for circular references
    if (visitedNodes.contains(node.id)) {
      errors.add(ValidationError(
        nodeId: node.id,
        message: 'Circular reference detected',
        type: ValidationErrorType.circularReference,
      ));
      return;
    }

    visitedNodes.add(node.id);

    // Validate node properties
    if (node.title.value.isEmpty) {
      errors.add(ValidationError(
        nodeId: node.id,
        message: 'Node title cannot be empty',
        type: ValidationErrorType.missingTitle,
      ));
    }

    // Validate node-specific requirements
    switch (node.type.value) {
      case NodeType.condition:
        if (node.trueConnection == null && node.falseConnection == null) {
          errors.add(ValidationError(
            nodeId: node.id,
            message: 'Condition node must have at least one connection',
            type: ValidationErrorType.missingConnection,
          ));
        }
        break;
      case NodeType.action:
        final actionType = node.properties.value['actionType'];
        if (actionType == null || actionType.toString().isEmpty) {
          errors.add(ValidationError(
            nodeId: node.id,
            message: 'Action node must specify an action type',
            type: ValidationErrorType.missingProperty,
          ));
        }
        break;
      case NodeType.output:
        // Output nodes are terminal, no specific validation needed
        break;
    }

    // Recursively validate connected nodes
    if (node.trueConnection != null) {
      _validateNode(node.trueConnection!, errors, Set.from(visitedNodes));
    }
    if (node.falseConnection != null) {
      _validateNode(node.falseConnection!, errors, Set.from(visitedNodes));
    }
    if (node.nextConnection != null) {
      _validateNode(node.nextConnection!, errors, Set.from(visitedNodes));
    }
  }
}

class ValidationError {
  final String nodeId;
  final String message;
  final ValidationErrorType type;

  ValidationError({
    required this.nodeId,
    required this.message,
    required this.type,
  });

  @override
  String toString() => 'ValidationError(nodeId: $nodeId, message: $message)';
}

enum ValidationErrorType {
  circularReference,
  missingTitle,
  missingConnection,
  missingProperty,
  invalidProperty,
}