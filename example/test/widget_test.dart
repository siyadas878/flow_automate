// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_workflow_builder/flutter_workflow_builder.dart';
import 'package:flutter_workflow_builder/models/workflow_config.dart';
import 'package:flutter_workflow_builder/widgets/workflow_json_preview.dart';
import 'package:flutter_workflow_builder/widgets/workflow_properties_panel.dart';

void main() {
  group('Workflow Widget Tests', () {
    testWidgets('WorkflowCanvas should render without nodes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowCanvas(
              onWorkflowGenerated: (workflow) {},
            ),
          ),
        ),
      );

      expect(find.byType(WorkflowCanvas), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Workflow Builder'), findsOneWidget);
    });

    testWidgets('WorkflowCanvas should render with initial nodes',
        (WidgetTester tester) async {
      final testNode = WorkflowNode(
        id: 'test_node',
        initialPosition: const Offset(100, 100),
        initialTitle: 'Test Node',
        initialType: NodeType.condition,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowCanvas(
              initialNodes: [testNode],
              onWorkflowGenerated: (workflow) {},
            ),
          ),
        ),
      );

      expect(find.byType(WorkflowNodeWidget), findsOneWidget);
      expect(find.text('Test Node'), findsOneWidget);
    });

    testWidgets('WorkflowCanvas should show add button in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowCanvas(
              onWorkflowGenerated: (workflow) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.code), findsOneWidget);
    });

    testWidgets('WorkflowNodeWidget should display node information',
        (WidgetTester tester) async {
      final testNode = WorkflowNode(
        id: 'display_test',
        initialPosition: const Offset(0, 0),
        initialTitle: 'Display Test Node',
        initialDescription: 'This is a test description',
        initialType: NodeType.action,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowNodeWidget(
              node: testNode,
              config: const WorkflowConfig(),
              onConnectTrue: () {},
              onConnectFalse: () {},
              onConnectNext: () {},
            ),
          ),
        ),
      );

      expect(find.text('Display Test Node'), findsOneWidget);
      expect(find.text('This is a test description'), findsOneWidget);
    });

    testWidgets('WorkflowNodeWidget should show correct icon for node type',
        (WidgetTester tester) async {
      final conditionNode = WorkflowNode(
        id: 'condition_test',
        initialPosition: const Offset(0, 0),
        initialType: NodeType.condition,
        initialTitle: 'Condition Node',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowNodeWidget(
              node: conditionNode,
              config: const WorkflowConfig(),
              onConnectTrue: () {},
              onConnectFalse: () {},
              onConnectNext: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });

    testWidgets(
        'WorkflowNodeWidget should show connection buttons for condition node',
        (WidgetTester tester) async {
      final conditionNode = WorkflowNode(
        id: 'connection_test',
        initialPosition: const Offset(0, 0),
        initialType: NodeType.condition,
        initialTitle: 'Connection Test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowNodeWidget(
              node: conditionNode,
              config: const WorkflowConfig(),
              onConnectTrue: () {},
              onConnectFalse: () {},
              onConnectNext: () {},
            ),
          ),
        ),
      );

      expect(find.text('True'), findsOneWidget);
      expect(find.text('False'), findsOneWidget);
    });

    testWidgets(
        'WorkflowNodeWidget should show only next button for action node',
        (WidgetTester tester) async {
      final actionNode = WorkflowNode(
        id: 'action_test',
        initialPosition: const Offset(0, 0),
        initialType: NodeType.action,
        initialTitle: 'Action Test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowNodeWidget(
              node: actionNode,
              config: const WorkflowConfig(),
              onConnectTrue: () {},
              onConnectFalse: () {},
              onConnectNext: () {},
            ),
          ),
        ),
      );

      expect(find.text('Next'), findsOneWidget);
      expect(find.text('True'), findsNothing);
      expect(find.text('False'), findsNothing);
    });

    testWidgets('WorkflowCanvas should handle node tap',
        (WidgetTester tester) async {
      final testNode = WorkflowNode(
        id: 'tap_test',
        initialPosition: const Offset(100, 100),
        initialTitle: 'Tap Test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowCanvas(
              initialNodes: [testNode],
              onWorkflowGenerated: (workflow) {},
            ),
          ),
        ),
      );

      expect(testNode.isSelected.value, isFalse);

      await tester.tap(find.byType(WorkflowNodeWidget));
      await tester.pump();

      expect(testNode.isSelected.value, isTrue);
    });

    testWidgets(
        'WorkflowCanvas should show properties panel when node selected',
        (WidgetTester tester) async {
      final testNode = WorkflowNode(
        id: 'properties_test',
        initialPosition: const Offset(100, 100),
        initialTitle: 'Properties Test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowCanvas(
              initialNodes: [testNode],
              onWorkflowGenerated: (workflow) {},
            ),
          ),
        ),
      );

      // Initially, properties panel should not be visible
      expect(find.byType(WorkflowPropertiesPanel), findsNothing);

      // Tap node to select it
      await tester.tap(find.byType(WorkflowNodeWidget));
      await tester.pump();

      // Properties panel should now be visible
      expect(find.byType(WorkflowPropertiesPanel), findsOneWidget);
    });

    testWidgets('WorkflowCanvas should generate JSON when code button pressed',
        (WidgetTester tester) async {
      Map<String, dynamic>? generatedWorkflow;

      final testNode = WorkflowNode(
        id: 'json_test',
        initialPosition: const Offset(0, 0),
        initialTitle: 'JSON Test Node',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowCanvas(
              initialNodes: [testNode],
              onWorkflowGenerated: (workflow) {
                generatedWorkflow = workflow;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.code));
      await tester.pump();

      expect(generatedWorkflow, isNotNull);
      expect(generatedWorkflow!['id'], equals('json_test'));
      expect(find.byType(WorkflowJsonPreview), findsOneWidget);
    });

    testWidgets('WorkflowPropertiesPanel should display node properties',
        (WidgetTester tester) async {
      final testNode = WorkflowNode(
        id: 'props_display_test',
        initialPosition: const Offset(0, 0),
        initialTitle: 'Properties Display Test',
        initialDescription: 'Test description',
        initialType: NodeType.condition,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowPropertiesPanel(
              node: testNode,
              onClose: () {},
              onDelete: () {},
              onPropertyChanged: () {},
            ),
          ),
        ),
      );

      expect(find.text('Edit Node: props_display_test'), findsOneWidget);
      expect(find.text('Basic Properties'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('WorkflowPropertiesPanel should show delete confirmation',
        (WidgetTester tester) async {
      final testNode = WorkflowNode(
        id: 'delete_test',
        initialPosition: const Offset(0, 0),
        initialTitle: 'Delete Test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowPropertiesPanel(
              node: testNode,
              onClose: () {},
              onDelete: () {},
              onPropertyChanged: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(find.text('Delete Node'), findsOneWidget);
      expect(find.text('Are you sure you want to delete node "delete_test"?'),
          findsOneWidget);
    });

    testWidgets('WorkflowJsonPreview should display JSON content',
        (WidgetTester tester) async {
      final testNode = WorkflowNode(
        id: 'json_preview_test',
        initialPosition: const Offset(0, 0),
        initialTitle: 'JSON Preview Test',
        initialType: NodeType.output,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowJsonPreview(
              rootNode: testNode,
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('Workflow JSON'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('JSON'), findsOneWidget);
      expect(find.text('Validation'), findsOneWidget);
    });

    testWidgets('WorkflowJsonPreview should show validation results',
        (WidgetTester tester) async {
      final invalidNode = WorkflowNode(
        id: 'invalid_test',
        initialPosition: const Offset(0, 0),
        initialTitle: '', // Empty title should cause validation error
        initialType: NodeType.condition,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowJsonPreview(
              rootNode: invalidNode,
              onClose: () {},
            ),
          ),
        ),
      );

      // Switch to validation tab
      await tester.tap(find.text('Validation'));
      await tester.pump();

      expect(find.textContaining('validation errors found'), findsOneWidget);
    });
  });

  group('Workflow Configuration Tests', () {
    testWidgets('WorkflowCanvas should apply custom configuration',
        (WidgetTester tester) async {
      const customConfig = WorkflowConfig(
        primaryColor: Colors.red,
        backgroundColor: Colors.black,
        showGrid: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowCanvas(
              config: customConfig,
              onWorkflowGenerated: (workflow) {},
            ),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(Colors.red));
    });

    testWidgets('WorkflowNodeWidget should apply custom configuration',
        (WidgetTester tester) async {
      const customConfig = WorkflowConfig(
        nodeWidth: 300.0,
        nodeHeight: 150.0,
      );

      final testNode = WorkflowNode(
        id: 'config_test',
        initialPosition: const Offset(0, 0),
        initialTitle: 'Config Test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowNodeWidget(
              node: testNode,
              onConnectTrue: () {},
              onConnectFalse: () {},
              onConnectNext: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('Config Test'),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.maxWidth, equals(300.0));
    });
  });

  group('Error Handling Tests', () {
    testWidgets('WorkflowCanvas should handle empty node list gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowCanvas(
              initialNodes: [],
              onWorkflowGenerated: (workflow) {},
            ),
          ),
        ),
      );

      expect(find.byType(WorkflowCanvas), findsOneWidget);
      expect(find.byType(WorkflowNodeWidget), findsNothing);
    });

    testWidgets('WorkflowJsonPreview should handle null root node',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowJsonPreview(
              rootNode: null,
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WorkflowJsonPreview), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });
  });
}
