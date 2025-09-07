// example/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_workflow_builder/flutter_workflow_builder.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workflow Builder Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic>? generatedWorkflow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WorkflowCanvas(
        onWorkflowGenerated: (workflow) {
          setState(() {
            generatedWorkflow = workflow;
          });
          
          // Use the generated workflow
          print('Generated Workflow: $workflow');
          
          // You can now execute this workflow or save it
          _executeWorkflow(workflow);
        },
        onNodesChanged: (nodes) {
          print('Nodes updated: ${nodes.length} nodes');
        },
      ),
    );
  }

  void _executeWorkflow(Map<String, dynamic> workflow) {
    // Implement your workflow execution logic here
    // This could involve:
    // - Making API calls based on conditions
    // - Executing automated tasks
    // - Triggering other systems
    
    print('Executing workflow...');
    _processWorkflowNode(workflow);
  }

  void _processWorkflowNode(Map<String, dynamic> node) {
    final nodeType = node['type'];
    
    switch (nodeType) {
      case 'condition':
        // Evaluate condition and follow true/false path
        final conditionResult = _evaluateCondition(node);
        if (conditionResult && node.containsKey('true_statement')) {
          _processWorkflowNode(node['true_statement']);
        } else if (!conditionResult && node.containsKey('false_statement')) {
          _processWorkflowNode(node['false_statement']);
        }
        break;
        
      case 'action':
        // Execute action
        _executeAction(node);
        if (node.containsKey('next')) {
          _processWorkflowNode(node['next']);
        }
        break;
        
      case 'output':
        // Generate output
        _generateOutput(node);
        break;
    }
  }

  bool _evaluateCondition(Map<String, dynamic> node) {
    // Implement your condition evaluation logic
    return true; // Placeholder
  }

  void _executeAction(Map<String, dynamic> node) {
    // Implement your action execution logic
    print('Executing action: ${node['title']}');
  }

  void _generateOutput(Map<String, dynamic> node) {
    // Implement your output generation logic
    print('Generating output: ${node['title']}');
  }
}