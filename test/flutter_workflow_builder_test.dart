// test/flutter_workflow_builder_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_workflow_builder/flutter_workflow_builder.dart';
import 'package:flutter_workflow_builder/models/workflow_config.dart';
import 'package:flutter_workflow_builder/utils/coordinate_transformer.dart';
import 'package:flutter_workflow_builder/utils/json_generator.dart';

void main() {
  group('Flutter Workflow Builder', () {
    test('WorkflowNode should create with default values', () {
      final node = WorkflowNode(
        id: 'test_node',
        initialPosition: const Offset(100, 200),
      );

      expect(node.id, equals('test_node'));
      expect(node.position.value, equals(const Offset(100, 200)));
      expect(node.type.value, equals(NodeType.condition));
      expect(node.title.value, isEmpty);
      expect(node.isSelected.value, isFalse);
    });

    test('WorkflowNode should update reactive properties', () {
      final node = WorkflowNode(
        id: 'reactive_node',
        initialPosition: Offset.zero,
      );

      // Test position update
      node.position.value = const Offset(150, 250);
      expect(node.position.value, equals(const Offset(150, 250)));

      // Test title update
      node.title.value = 'Updated Title';
      expect(node.title.value, equals('Updated Title'));

      // Test selection state
      node.isSelected.value = true;
      expect(node.isSelected.value, isTrue);
    });

    test('WorkflowNode should generate correct JSON', () {
      final node = WorkflowNode(
        id: 'json_node',
        initialPosition: const Offset(100, 200),
        initialType: NodeType.action,
        initialTitle: 'Test Action',
        initialProperties: {
          'actionType': 'api_call',
          'endpoint': '/api/test',
        },
      );

      final json = node.toJson();

      expect(json['id'], equals('json_node'));
      expect(json['type'], equals('action'));
      expect(json['title'], equals('Test Action'));
      expect(json['properties']['actionType'], equals('api_call'));
      expect(json['properties']['endpoint'], equals('/api/test'));
    });

    test('WorkflowConnection should link nodes correctly', () {
      final sourceNode = WorkflowNode(
        id: 'source',
        initialPosition: Offset.zero,
      );

      final targetNode = WorkflowNode(
        id: 'target',
        initialPosition: const Offset(100, 100),
      );

      final connection = WorkflowConnection(
        source: sourceNode,
        target: targetNode,
        type: 'true',
      );

      expect(connection.source.id, equals('source'));
      expect(connection.target.id, equals('target'));
      expect(connection.type, equals('true'));
    });

    test('WorkflowConfig should have default values', () {
      const config = WorkflowConfig();

      expect(config.primaryColor, equals(Colors.blue));
      expect(config.backgroundColor, equals(Colors.white));
      expect(config.nodeWidth, equals(200.0));
      expect(config.nodeHeight, equals(120.0));
      expect(config.showGrid, isTrue);
      expect(config.enableSnapping, isFalse);
    });

    test('WorkflowConfig copyWith should work correctly', () {
      const originalConfig = WorkflowConfig();

      final newConfig = originalConfig.copyWith(
        primaryColor: Colors.red,
        nodeWidth: 300.0,
      );

      expect(newConfig.primaryColor, equals(Colors.red));
      expect(newConfig.nodeWidth, equals(300.0));
      expect(newConfig.backgroundColor, equals(Colors.white)); // Unchanged
      expect(newConfig.nodeHeight, equals(120.0)); // Unchanged
    });

    test('CoordinateTransformer should calculate bounds correctly', () {
      final transformer = CoordinateTransformer();
      final nodes = [
        WorkflowNode(id: '1', initialPosition: const Offset(0, 0)),
        WorkflowNode(id: '2', initialPosition: const Offset(100, 50)),
        WorkflowNode(id: '3', initialPosition: const Offset(-50, 200)),
      ];

      transformer.calculateBounds(nodes);

      expect(transformer.canvasSize.width, greaterThan(0));
      expect(transformer.canvasSize.height, greaterThan(0));
    });

    test('NodeType enum should have correct values', () {
      expect(NodeType.values.length, equals(3));
      expect(NodeType.values, contains(NodeType.condition));
      expect(NodeType.values, contains(NodeType.action));
      expect(NodeType.values, contains(NodeType.output));
    });

    test('WorkflowNode connections should work', () {
      final rootNode = WorkflowNode(
        id: 'root',
        initialPosition: Offset.zero,
        initialType: NodeType.condition,
      );

      final trueNode = WorkflowNode(
        id: 'true_branch',
        initialPosition: const Offset(100, 100),
        initialType: NodeType.action,
      );

      final falseNode = WorkflowNode(
        id: 'false_branch',
        initialPosition: const Offset(200, 100),
        initialType: NodeType.output,
      );

      // Establish connections
      rootNode.trueConnection = trueNode;
      rootNode.falseConnection = falseNode;

      expect(rootNode.trueConnection?.id, equals('true_branch'));
      expect(rootNode.falseConnection?.id, equals('false_branch'));
      expect(rootNode.nextConnection, isNull);
    });

    test('WorkflowNode should generate JSON with connections', () {
      final rootNode = WorkflowNode(
        id: 'root',
        initialPosition: Offset.zero,
        initialType: NodeType.condition,
        initialTitle: 'Root Condition',
      );

      final actionNode = WorkflowNode(
        id: 'action',
        initialPosition: const Offset(100, 100),
        initialType: NodeType.action,
        initialTitle: 'Action Node',
      );

      rootNode.trueConnection = actionNode;

      final json = rootNode.toJson();

      expect(json['true_statement'], isNotNull);
      expect(json['true_statement']['id'], equals('action'));
      expect(json['true_statement']['type'], equals('action'));
      expect(json['true_statement']['title'], equals('Action Node'));
    });
  });

  group('Workflow Validation', () {
    test('should validate empty workflow', () {
      final errors = JsonGenerator.validateWorkflow(
        WorkflowNode(id: 'empty', initialPosition: Offset.zero),
      );

      expect(errors, isNotEmpty);
      expect(errors.any((e) => e.type == ValidationErrorType.missingTitle),
          isTrue);
    });

    test('should validate condition node without connections', () {
      final node = WorkflowNode(
        id: 'lonely_condition',
        initialPosition: Offset.zero,
        initialType: NodeType.condition,
        initialTitle: 'Lonely Condition',
      );

      final errors = JsonGenerator.validateWorkflow(node);

      expect(errors.any((e) => e.type == ValidationErrorType.missingConnection),
          isTrue);
    });

    test('should validate action node without action type', () {
      final node = WorkflowNode(
        id: 'incomplete_action',
        initialPosition: Offset.zero,
        initialType: NodeType.action,
        initialTitle: 'Incomplete Action',
      );

      final errors = JsonGenerator.validateWorkflow(node);

      expect(errors.any((e) => e.type == ValidationErrorType.missingProperty),
          isTrue);
    });
  });

  group('JSON Generation', () {
    test('should generate valid JSON string', () {
      final node = WorkflowNode(
        id: 'json_test',
        initialPosition: const Offset(0, 0),
        initialTitle: 'JSON Test Node',
        initialType: NodeType.output,
      );

      final jsonString = JsonGenerator.generateWorkflowJson(node);

      expect(jsonString, isNotEmpty);
      expect(jsonString, contains('"id": "json_test"'));
      expect(jsonString, contains('"type": "output"'));
      expect(jsonString, contains('"title": "JSON Test Node"'));
    });

    test('should parse JSON back to node', () {
      const jsonString = '''
      {
        "id": "parsed_node",
        "type": "condition",
        "title": "Parsed Node",
        "description": "A parsed node",
        "properties": {
          "field": "age",
          "operator": ">=",
          "value": 18
        },
        "position": {
          "x": 100.0,
          "y": 200.0
        }
      }
      ''';

      final node = JsonGenerator.parseWorkflowJson(jsonString);

      expect(node, isNotNull);
      expect(node!.id, equals('parsed_node'));
      expect(node.type.value, equals(NodeType.condition));
      expect(node.title.value, equals('Parsed Node'));
      expect(node.description.value, equals('A parsed node'));
      expect(node.properties.value['field'], equals('age'));
      expect(node.position.value, equals(const Offset(100.0, 200.0)));
    });

    test('should handle invalid JSON gracefully', () {
      const invalidJson = '{ invalid json }';

      expect(() => JsonGenerator.parseWorkflowJson(invalidJson),
          throwsA(isA<FormatException>()));
    });
  });
}
