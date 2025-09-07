import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_workflow_builder/flutter_workflow_builder.dart';
import 'package:flutter_workflow_builder/widgets/workflow_json_preview.dart';
import 'package:flutter_workflow_builder/widgets/workflow_properties_panel.dart';

void main() {
  group('WorkflowCanvas', () {
    testWidgets('should render without initial nodes', (tester) async {
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
    });

    testWidgets('should render with initial nodes', (tester) async {
      final nodes = [
        WorkflowNode(
          id: 'test_node',
          initialPosition: const Offset(100, 100),
          initialTitle: 'Test Node',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowCanvas(
              initialNodes: nodes,
              onWorkflowGenerated: (workflow) {},
            ),
          ),
        ),
      );

      expect(find.byType(WorkflowCanvas), findsOneWidget);
      expect(find.byType(WorkflowNodeWidget), findsOneWidget);
      expect(find.text('Test Node'), findsOneWidget);
    });

    testWidgets('should call onWorkflowGenerated when generating workflow', (tester) async {
      Map<String, dynamic>? generatedWorkflow;
      
      final nodes = [
        WorkflowNode(
          id: 'root',
          initialPosition: const Offset(0, 0),
          initialTitle: 'Root Node',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowCanvas(
              initialNodes: nodes,
              onWorkflowGenerated: (workflow) {
                generatedWorkflow = workflow;
              },
            ),
          ),
        ),
      );

      // Find and tap the generate JSON button (assuming it exists in the app bar)
      await tester.tap(find.byIcon(Icons.code));
      await tester.pump();

      expect(generatedWorkflow, isNotNull);
      expect(generatedWorkflow!['id'], equals('root'));
      expect(generatedWorkflow!['title'], equals('Root Node'));
    });

    testWidgets('should handle node selection', (tester) async {
      final node = WorkflowNode(
        id: 'selectable_node',
        initialPosition: const Offset(100, 100),
        initialTitle: 'Selectable Node',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowCanvas(
              initialNodes: [node],
              onWorkflowGenerated: (workflow) {},
            ),
          ),
        ),
      );

      expect(node.isSelected.value, isFalse);

      // Tap on the node to select it
      await tester.tap(find.byType(WorkflowNodeWidget));
      await tester.pump();

      expect(node.isSelected.value, isTrue);
    });

    testWidgets('should handle node dragging', (tester) async {
      final node = WorkflowNode(
        id: 'draggable_node',
        initialPosition: const Offset(100, 100),
        initialTitle: 'Draggable Node',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowCanvas(
              initialNodes: [node],
              onWorkflowGenerated: (workflow) {},
            ),
          ),
        ),
      );

      final initialPosition = node.position.value;

      // Drag the node
      await tester.drag(find.byType(WorkflowNodeWidget), const Offset(50, 50));
      await tester.pump();

      expect(node.position.value, isNot(equals(initialPosition)));
    });

    testWidgets('should call onNodesChanged when nodes are modified', (tester) async {
      List<WorkflowNode>? changedNodes;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowCanvas(
              onWorkflowGenerated: (workflow) {},
              onNodesChanged: (nodes) {
                changedNodes = nodes;
              },
            ),
          ),
        ),
      );

      // Add a node (assuming there's an add button)
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(changedNodes, isNotNull);
      expect(changedNodes!.length, greaterThan(0));
    });
  });

  group('WorkflowCanvas Integration', () {
    testWidgets('should show properties panel when node is selected', (tester) async {
      final node = WorkflowNode(
        id: 'editable_node',
        initialPosition: const Offset(100, 100),
        initialTitle: 'Editable Node',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowCanvas(
              initialNodes: [node],
              onWorkflowGenerated: (workflow) {},
            ),
          ),
        ),
      );

      // Initially, properties panel should not be visible
      expect(find.byType(WorkflowPropertiesPanel), findsNothing);

      // Select the node
      await tester.tap(find.byType(WorkflowNodeWidget));
      await tester.pump();

      // Properties panel should now be visible
      expect(find.byType(WorkflowPropertiesPanel), findsOneWidget);
    });

    testWidgets('should show JSON preview when requested', (tester) async {
      final node = WorkflowNode(
        id: 'json_node',
        initialPosition: const Offset(100, 100),
        initialTitle: 'JSON Node',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowCanvas(
              initialNodes: [node],
              onWorkflowGenerated: (workflow) {},
            ),
          ),
        ),
      );

      // Initially, JSON preview should not be visible
      expect(find.byType(WorkflowJsonPreview), findsNothing);

      // Tap the generate JSON button
      await tester.tap(find.byIcon(Icons.code));
      await tester.pump();

      // JSON preview should now be visible
      expect(find.byType(WorkflowJsonPreview), findsOneWidget);
    });
  });
}