import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_workflow_builder/flutter_workflow_builder.dart';

void main() {
  group('WorkflowNode', () {
    test('should create node with default values', () {
      final node = WorkflowNode(
        id: 'test_node',
        initialPosition: const Offset(100, 200),
      );

      expect(node.id, equals('test_node'));
      expect(node.position.value, equals(const Offset(100, 200)));
      expect(node.type.value, equals(NodeType.condition));
      expect(node.title.value, isEmpty);
      expect(node.description.value, isEmpty);
      expect(node.properties.value, isEmpty);
      expect(node.isSelected.value, isFalse);
      expect(node.trueConnection, isNull);
      expect(node.falseConnection, isNull);
      expect(node.nextConnection, isNull);
    });

    test('should create node with custom values', () {
      final properties = {'field': 'age', 'operator': '>', 'value': 18};
      
      final node = WorkflowNode(
        id: 'custom_node',
        initialPosition: const Offset(50, 75),
        initialType: NodeType.action,
        initialTitle: 'Custom Node',
        initialDescription: 'This is a custom node',
        initialProperties: properties,
      );

      expect(node.id, equals('custom_node'));
      expect(node.position.value, equals(const Offset(50, 75)));
      expect(node.type.value, equals(NodeType.action));
      expect(node.title.value, equals('Custom Node'));
      expect(node.description.value, equals('This is a custom node'));
      expect(node.properties.value, equals(properties));
    });

    test('should update reactive properties', () {
      final node = WorkflowNode(
        id: 'reactive_node',
        initialPosition: Offset.zero,
      );

      // Test position update
      node.position.value = const Offset(150, 250);
      expect(node.position.value, equals(const Offset(150, 250)));

      // Test type update
      node.type.value = NodeType.output;
      expect(node.type.value, equals(NodeType.output));

      // Test title update
      node.title.value = 'Updated Title';
      expect(node.title.value, equals('Updated Title'));

      // Test description update
      node.description.value = 'Updated Description';
      expect(node.description.value, equals('Updated Description'));

      // Test properties update
      final newProperties = {'key': 'value'};
      node.properties.value = newProperties;
      expect(node.properties.value, equals(newProperties));

      // Test selection state
      node.isSelected.value = true;
      expect(node.isSelected.value, isTrue);
    });

    test('should establish connections between nodes', () {
      final sourceNode = WorkflowNode(
        id: 'source',
        initialPosition: Offset.zero,
      );

      final trueNode = WorkflowNode(
        id: 'true_target',
        initialPosition: const Offset(100, 100),
      );

      final falseNode = WorkflowNode(
        id: 'false_target',
        initialPosition: const Offset(200, 100),
      );

      final nextNode = WorkflowNode(
        id: 'next_target',
        initialPosition: const Offset(300, 100),
      );

      // Establish connections
      sourceNode.trueConnection = trueNode;
      sourceNode.falseConnection = falseNode;
      sourceNode.nextConnection = nextNode;

      expect(sourceNode.trueConnection, equals(trueNode));
      expect(sourceNode.falseConnection, equals(falseNode));
      expect(sourceNode.nextConnection, equals(nextNode));
    });

    test('should generate correct JSON', () {
      final node = WorkflowNode(
        id: 'json_node',
        initialPosition: const Offset(100, 200),
        initialType: NodeType.condition,
        initialTitle: 'Test Condition',
        initialDescription: 'A test condition node',
        initialProperties: {
          'field': 'age',
          'operator': '>=',
          'value': 18,
        },
      );

      final json = node.toJson();

      expect(json['id'], equals('json_node'));
      expect(json['type'], equals('condition'));
      expect(json['title'], equals('Test Condition'));
      expect(json['description'], equals('A test condition node'));
      expect(json['properties']['field'], equals('age'));
      expect(json['properties']['operator'], equals('>='));
      expect(json['properties']['value'], equals(18));
      expect(json['position']['x'], equals(100.0));
      expect(json['position']['y'], equals(200.0));
    });

    test('should generate JSON with connections', () {
      final rootNode = WorkflowNode(
        id: 'root',
        initialPosition: Offset.zero,
        initialType: NodeType.condition,
        initialTitle: 'Root Node',
      );

      final trueNode = WorkflowNode(
        id: 'true_branch',
        initialPosition: const Offset(100, 100),
        initialType: NodeType.action,
        initialTitle: 'True Branch',
      );

      final falseNode = WorkflowNode(
        id: 'false_branch',
        initialPosition: const Offset(200, 100),
        initialType: NodeType.output,
        initialTitle: 'False Branch',
      );

      rootNode.trueConnection = trueNode;
      rootNode.falseConnection = falseNode;

      final json = rootNode.toJson();

      expect(json['true_statement'], isNotNull);
      expect(json['true_statement']['id'], equals('true_branch'));
      expect(json['true_statement']['type'], equals('action'));

      expect(json['false_statement'], isNotNull);
      expect(json['false_statement']['id'], equals('false_branch'));
      expect(json['false_statement']['type'], equals('output'));
    });

    test('should parse JSON back to node', () {
      final jsonData = {
        'id': 'parsed_node',
        'type': 'action',
        'title': 'Parsed Node',
        'description': 'A node parsed from JSON',
        'properties': {
          'actionType': 'api_call',
          'endpoint': '/api/test',
        },
        'position': {
          'x': 150.0,
          'y': 250.0,
        },
      };

      final node = WorkflowNode.fromJson(jsonData, const Offset(150, 250));

      expect(node.id, equals('parsed_node'));
      expect(node.type.value, equals(NodeType.action));
      expect(node.title.value, equals('Parsed Node'));
      expect(node.description.value, equals('A node parsed from JSON'));
      expect(node.properties.value['actionType'], equals('api_call'));
      expect(node.properties.value['endpoint'], equals('/api/test'));
      expect(node.position.value, equals(const Offset(150, 250)));
    });
  });

  group('WorkflowNode Validation', () {
    test('should validate condition node properties', () {
      final node = WorkflowNode(
        id: 'condition_node',
        initialPosition: Offset.zero,
        initialType: NodeType.condition,
        initialProperties: {
          'field': 'age',
          'operator': '>=',
          'value': 18,
        },
      );

      expect(node.properties.value['field'], isNotNull);
      expect(node.properties.value['operator'], isNotNull);
      expect(node.properties.value['value'], isNotNull);
    });

    test('should validate action node properties', () {
      final node = WorkflowNode(
        id: 'action_node',
        initialPosition: Offset.zero,
        initialType: NodeType.action,
        initialProperties: {
          'actionType': 'api_call',
          'endpoint': '/api/process',
          'method': 'POST',
        },
      );

      expect(node.properties.value['actionType'], equals('api_call'));
      expect(node.properties.value['endpoint'], equals('/api/process'));
      expect(node.properties.value['method'], equals('POST'));
    });

    test('should validate output node properties', () {
      final node = WorkflowNode(
        id: 'output_node',
        initialPosition: Offset.zero,
        initialType: NodeType.output,
        initialProperties: {
          'outputFormat': 'json',
          'destination': 'file',
          'template': '{"result": "{{value}}"}',
        },
      );

      expect(node.properties.value['outputFormat'], equals('json'));
      expect(node.properties.value['destination'], equals('file'));
      expect(node.properties.value['template'], contains('result'));
    });
  });
}