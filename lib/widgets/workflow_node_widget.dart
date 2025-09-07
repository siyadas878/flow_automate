// lib/widgets/workflow_node_widget.dart
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../models/workflow_node.dart';
import '../models/workflow_config.dart';

class WorkflowNodeWidget extends StatelessWidget {
  final WorkflowNode node;
  final WorkflowConfig config;
  final VoidCallback? onConnectTrue;
  final VoidCallback? onConnectFalse;
  final VoidCallback? onConnectNext;

  const WorkflowNodeWidget({
    super.key,
    required this.node,
    this.config = const WorkflowConfig(),
    this.onConnectTrue,
    this.onConnectFalse,
    this.onConnectNext,
  });

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isSelected = node.isSelected.value;
      final nodeType = node.type.value;

      Color primaryColor;
      IconData icon;

      switch (nodeType) {
        case NodeType.condition:
          primaryColor = config.primaryColor;
          icon = Icons.help_outline;
          break;
        case NodeType.action:
          primaryColor = Colors.green;
          icon = Icons.play_arrow;
          break;
        case NodeType.output:
          primaryColor = Colors.orange;
          icon = Icons.output;
          break;
      }

      return Container(
        width: config.nodeWidth,
        constraints: BoxConstraints(
          maxWidth: config.nodeWidth,
          minHeight: config.nodeHeight,
        ),
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : config.secondaryColor.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      node.title.value.isEmpty ? 'Untitled' : node.title.value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                node.description.value.isEmpty
                    ? 'No description'
                    : node.description.value,
                style: TextStyle(
                  fontSize: 12,
                  color: config.secondaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Connection buttons
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildConnectionButtons(nodeType),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildConnectionButtons(NodeType nodeType) {
    switch (nodeType) {
      case NodeType.condition:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildConnectionButton('True', Colors.green, onConnectTrue),
            _buildConnectionButton('False', Colors.red, onConnectFalse),
          ],
        );
      case NodeType.action:
      case NodeType.output:
        return _buildConnectionButton('Next', Colors.blue, onConnectNext);
    }
  }

  Widget _buildConnectionButton(
    String label,
    Color color,
    VoidCallback? onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
