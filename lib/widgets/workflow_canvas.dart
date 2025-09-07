import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../models/workflow_node.dart';
import '../models/workflow_connection.dart';
import '../models/workflow_config.dart';
import '../painters/grid_painter.dart';
import '../painters/connection_painter.dart';
import '../utils/coordinate_transformer.dart';
import 'workflow_node_widget.dart';
import 'workflow_properties_panel.dart';
import 'workflow_json_preview.dart';

class WorkflowCanvas extends StatefulWidget {
  final List<WorkflowNode>? initialNodes;
  final Function(Map<String, dynamic>)? onWorkflowGenerated;
  final Function(List<WorkflowNode>)? onNodesChanged;
  final WorkflowConfig config;

  const WorkflowCanvas({
    super.key,
    this.initialNodes,
    this.onWorkflowGenerated,
    this.onNodesChanged,
    this.config = const WorkflowConfig(),
  });

  @override
  State<WorkflowCanvas> createState() => _WorkflowCanvasState();
}

class _WorkflowCanvasState extends State<WorkflowCanvas> {
  late List<WorkflowNode> nodes;
  late List<WorkflowConnection> connections;
  late CoordinateTransformer transformer;
  late TransformationController transformationController;

  final Signal<WorkflowNode?> selectedNode = signal(null);
  final Signal<bool> showJsonPreview = signal(false);

  // Connection creation state
  bool isCreatingConnection = false;
  WorkflowNode? connectionStartNode;
  String? connectionType;
  Offset? connectionEndPoint;

  // Dragging state
  WorkflowNode? draggingNode;
  Offset? dragOffset;

  @override
  void initState() {
    super.initState();
    nodes = widget.initialNodes ?? [];
    connections = [];
    transformer = CoordinateTransformer();
    transformationController = TransformationController();

    if (nodes.isEmpty) {
      _addInitialNode();
    }

    _calculateBounds();
  }

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }

  void _addInitialNode() {
    final node = WorkflowNode(
      id: 'node_1',
      initialPosition: const Offset(0, 0),
      initialTitle: 'Start Node',
      initialType: NodeType.condition,
    );
    nodes.add(node);
  }

  void _calculateBounds() {
    transformer.calculateBounds(nodes);
  }

  void _addNewNode() {
    final newNode = WorkflowNode(
      id: 'node_${nodes.length + 1}',
      initialPosition: Offset(
        (nodes.length * 300.0) % 1200,
        (nodes.length ~/ 4) * 200.0,
      ),
      initialTitle: 'New Node',
    );

    nodes.add(newNode);
    _calculateBounds();
    widget.onNodesChanged?.call(nodes);
    setState(() {});
  }

  void _generateWorkflow() {
    if (nodes.isEmpty) return;

    final rootNode = nodes.first;
    final workflowJson = rootNode.toJson();
    widget.onWorkflowGenerated?.call(workflowJson);
    showJsonPreview.value = true;
  }

  void _startConnection(WorkflowNode source, String type) {
    setState(() {
      isCreatingConnection = true;
      connectionStartNode = source;
      connectionType = type;

      final sourceCanvasPos =
          transformer.nodeToCanvasPosition(source.position.value);
      connectionEndPoint =
          Offset(sourceCanvasPos.dx + 100, sourceCanvasPos.dy + 60);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Click on a target node to connect, or tap anywhere to cancel'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _completeConnection(WorkflowNode target) {
    if (connectionStartNode != null && connectionType != null) {
      // Remove existing connection of the same type from source
      connections.removeWhere((conn) =>
          conn.source == connectionStartNode && conn.type == connectionType);

      // Create new connection
      final connection = WorkflowConnection(
        source: connectionStartNode!,
        target: target,
        type: connectionType!,
      );
      connections.add(connection);

      // Update node references
      switch (connectionType!) {
        case 'true':
          connectionStartNode!.trueConnection = target;
          break;
        case 'false':
          connectionStartNode!.falseConnection = target;
          break;
        case 'next':
          connectionStartNode!.nextConnection = target;
          break;
      }

      _cancelConnection();
      widget.onNodesChanged?.call(nodes);
    }
  }

  void _cancelConnection() {
    setState(() {
      isCreatingConnection = false;
      connectionStartNode = null;
      connectionType = null;
      connectionEndPoint = null;
    });
  }

  void _deleteNode(WorkflowNode node) {
    // Remove connections involving this node
    connections
        .removeWhere((conn) => conn.source == node || conn.target == node);

    // Remove node references
    for (final n in nodes) {
      if (n.trueConnection == node) n.trueConnection = null;
      if (n.falseConnection == node) n.falseConnection = null;
      if (n.nextConnection == node) n.nextConnection = null;
    }

    nodes.remove(node);
    selectedNode.value = null;
    _calculateBounds();
    widget.onNodesChanged?.call(nodes);
    setState(() {});
  }

  void _selectNode(WorkflowNode node) {
    for (final n in nodes) {
      n.isSelected.value = false;
    }
    node.isSelected.value = true;
    selectedNode.value = node;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workflow Builder'),
        backgroundColor: widget.config.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewNode,
            tooltip: 'Add Node',
          ),
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: _generateWorkflow,
            tooltip: 'Generate JSON',
          ),
        ],
      ),
      body: Watch((context) {
        final isShowingSidebar =
            showJsonPreview.value || selectedNode.value != null;

        return Row(
          children: [
            // Main Canvas
            Expanded(
              flex: isShowingSidebar ? 3 : 1,
              child: Container(
                color: widget.config.backgroundColor,
                child: InteractiveViewer(
                  transformationController: transformationController,
                  constrained: false,
                  boundaryMargin: EdgeInsets.zero,
                  minScale: 0.1,
                  maxScale: 3.0,
                  child: GestureDetector(
                    onTapDown: (details) {
                      if (isCreatingConnection) {
                        _cancelConnection();
                      }
                    },
                    onPanUpdate: (details) {
                      if (isCreatingConnection) {
                        setState(() {
                          connectionEndPoint = details.localPosition;
                        });
                      }
                    },
                    child: Container(
                      width: transformer.canvasSize.width,
                      height: transformer.canvasSize.height,
                      color: widget.config.backgroundColor,
                      child: Stack(
                        children: [
                          // Grid background
                          if (widget.config.showGrid)
                            CustomPaint(
                              size: transformer.canvasSize,
                              painter: GridPainter(
                                gridSize: widget.config.gridSize,
                                color: widget.config.secondaryColor
                                    .withOpacity(0.3),
                              ),
                            ),

                          // Connections
                          CustomPaint(
                            size: transformer.canvasSize,
                            painter: ConnectionPainter(
                              connections: connections,
                              transformer: transformer,
                              isCreatingConnection: isCreatingConnection,
                              connectionStartNode: connectionStartNode,
                              connectionEndPoint: connectionEndPoint,
                              connectionType: connectionType,
                            ),
                          ),

                          // Nodes
                          ..._buildNodes(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Side panels
            if (showJsonPreview.value)
              Expanded(
                flex: 2,
                child: WorkflowJsonPreview(
                  rootNode: nodes.isNotEmpty ? nodes.first : null,
                  onClose: () => showJsonPreview.value = false,
                ),
              )
            else if (selectedNode.value != null)
              Expanded(
                flex: 2,
                child: WorkflowPropertiesPanel(
                  node: selectedNode.value!,
                  onClose: () => selectedNode.value = null,
                  onDelete: () => _deleteNode(selectedNode.value!),
                  onPropertyChanged: () => setState(() {}),
                ),
              ),
          ],
        );
      }),
    );
  }

  List<Widget> _buildNodes() {
    return nodes.map((node) {
      final canvasPosition =
          transformer.nodeToCanvasPosition(node.position.value);

      return Positioned(
        left: canvasPosition.dx,
        top: canvasPosition.dy,
        child: GestureDetector(
          onTap: () {
            if (isCreatingConnection) {
              _completeConnection(node);
            } else {
              _selectNode(node);
            }
          },
          onPanStart: (details) {
            if (!isCreatingConnection) {
              draggingNode = node;
              dragOffset = details.localPosition;
              _selectNode(node);
            }
          },
          onPanUpdate: (details) {
            if (draggingNode == node &&
                dragOffset != null &&
                !isCreatingConnection) {
              final newPosition = Offset(
                node.position.value.dx + details.delta.dx,
                node.position.value.dy + details.delta.dy,
              );
              node.position.value = newPosition;
              setState(() {});
            }
          },
          onPanEnd: (details) {
            if (draggingNode == node) {
              draggingNode = null;
              dragOffset = null;
              _calculateBounds();
            }
          },
          child: WorkflowNodeWidget(
            node: node,
            config: widget.config,
            onConnectTrue: () => _startConnection(node, 'true'),
            onConnectFalse: () => _startConnection(node, 'false'),
            onConnectNext: () => _startConnection(node, 'next'),
          ),
        ),
      );
    }).toList();
  }
}
