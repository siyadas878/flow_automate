import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workflow_node.dart';

class WorkflowPropertiesPanel extends StatefulWidget {
  final WorkflowNode node;
  final VoidCallback onClose;
  final VoidCallback onDelete;
  final VoidCallback onPropertyChanged;

  const WorkflowPropertiesPanel({
    super.key,
    required this.node,
    required this.onClose,
    required this.onDelete,
    required this.onPropertyChanged,
  });

  @override
  State<WorkflowPropertiesPanel> createState() => _WorkflowPropertiesPanelState();
}

class _WorkflowPropertiesPanelState extends State<WorkflowPropertiesPanel> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late Map<String, TextEditingController> _propertyControllers;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.node.title.value);
    _descriptionController = TextEditingController(text: widget.node.description.value);
    _propertyControllers = {};
    
    // Initialize property controllers
    for (final entry in widget.node.properties.value.entries) {
      _propertyControllers[entry.key] = TextEditingController(
        text: entry.value.toString(),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _propertyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          left: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicProperties(),
                  const SizedBox(height: 24),
                  _buildNodeTypeSpecificProperties(),
                  const SizedBox(height: 24),
                  _buildCustomProperties(),
                  const SizedBox(height: 24),
                  _buildConnectionInfo(),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getNodeIcon(widget.node.type.value),
            color: _getNodeColor(widget.node.type.value),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Edit Node: ${widget.node.id}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteConfirmation,
            color: Colors.red,
            tooltip: 'Delete Node',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
            tooltip: 'Close Panel',
          ),
        ],
      ),
    );
  }

  Widget _buildBasicProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Properties',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Title',
          controller: _titleController,
          onChanged: (value) {
            widget.node.title.value = value;
            widget.onPropertyChanged();
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Description',
          controller: _descriptionController,
          maxLines: 3,
          onChanged: (value) {
            widget.node.description.value = value;
            widget.onPropertyChanged();
          },
        ),
        const SizedBox(height: 16),
        _buildNodeTypeDropdown(),
      ],
    );
  }

  Widget _buildNodeTypeSpecificProperties() {
    switch (widget.node.type.value) {
      case NodeType.condition:
        return _buildConditionProperties();
      case NodeType.action:
        return _buildActionProperties();
      case NodeType.output:
        return _buildOutputProperties();
    }
  }

  Widget _buildConditionProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condition Properties',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildPropertyField('field', 'Field Name'),
        const SizedBox(height: 12),
        _buildPropertyDropdown(
          'operator',
          'Operator',
          ['==', '!=', '>', '<', '>=', '<=', 'contains', 'startsWith', 'endsWith'],
        ),
        const SizedBox(height: 12),
        _buildPropertyField('value', 'Comparison Value'),
      ],
    );
  }

  Widget _buildActionProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Action Properties',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildPropertyDropdown(
          'actionType',
          'Action Type',
          ['api_call', 'email', 'notification', 'data_transform', 'delay', 'custom'],
        ),
        const SizedBox(height: 12),
        _buildPropertyField('endpoint', 'API Endpoint'),
        const SizedBox(height: 12),
        _buildPropertyField('method', 'HTTP Method'),
        const SizedBox(height: 12),
        _buildPropertyField('delay', 'Delay (seconds)', isNumber: true),
      ],
    );
  }

  Widget _buildOutputProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Output Properties',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildPropertyField('outputFormat', 'Output Format'),
        const SizedBox(height: 12),
        _buildPropertyField('destination', 'Destination'),
        const SizedBox(height: 12),
        _buildPropertyField('template', 'Template', maxLines: 3),
      ],
    );
  }

  Widget _buildCustomProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Custom Properties',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addCustomProperty,
              tooltip: 'Add Property',
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._buildCustomPropertyFields(),
      ],
    );
  }

  List<Widget> _buildCustomPropertyFields() {
    final properties = widget.node.properties.value;
    final widgets = <Widget>[];

    for (final entry in properties.entries) {
      if (!_isReservedProperty(entry.key)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildPropertyField(entry.key, entry.key),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removeCustomProperty(entry.key),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );
      }
    }

    if (widgets.isEmpty) {
      widgets.add(
        Text(
          'No custom properties',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildConnectionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connections',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildConnectionItem(
          'True Connection',
          widget.node.trueConnection?.id,
          Colors.green,
        ),
        _buildConnectionItem(
          'False Connection',
          widget.node.falseConnection?.id,
          Colors.red,
        ),
        _buildConnectionItem(
          'Next Connection',
          widget.node.nextConnection?.id,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildConnectionItem(String label, String? nodeId, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: nodeId != null ? color : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: ${nodeId ?? 'Not connected'}',
              style: TextStyle(
                color: nodeId != null ? null : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onClose,
              child: const Text('Close'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumber
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
              : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
            isDense: true,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildNodeTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Node Type',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<NodeType>(
          value: widget.node.type.value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
            isDense: true,
          ),
          items: NodeType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Row(
                children: [
                  Icon(
                    _getNodeIcon(type),
                    color: _getNodeColor(type),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(type.name.toUpperCase()),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.node.type.value = value;
              widget.onPropertyChanged();
            }
          },
        ),
      ],
    );
  }

  Widget _buildPropertyField(String key, String label, {int maxLines = 1, bool isNumber = false}) {
    if (!_propertyControllers.containsKey(key)) {
      _propertyControllers[key] = TextEditingController(
        text: widget.node.properties.value[key]?.toString() ?? '',
      );
    }

    return _buildTextField(
      label: label,
      controller: _propertyControllers[key]!,
      maxLines: maxLines,
      isNumber: isNumber,
      onChanged: (value) {
        final properties = Map<String, dynamic>.from(widget.node.properties.value);
        if (isNumber) {
          properties[key] = double.tryParse(value) ?? value;
        } else {
          properties[key] = value;
        }
        widget.node.properties.value = properties;
        widget.onPropertyChanged();
      },
    );
  }

  Widget _buildPropertyDropdown(String key, String label, List<String> options) {
    final currentValue = widget.node.properties.value[key]?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: options.contains(currentValue) ? currentValue : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
            isDense: true,
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              final properties = Map<String, dynamic>.from(widget.node.properties.value);
              properties[key] = value;
              widget.node.properties.value = properties;
              widget.onPropertyChanged();
            }
          },
        ),
      ],
    );
  }

  void _addCustomProperty() {
    showDialog(
      context: context,
      builder: (context) {
        String propertyName = '';
        return AlertDialog(
          title: const Text('Add Custom Property'),
          content: TextField(
            onChanged: (value) => propertyName = value,
            decoration: const InputDecoration(
              labelText: 'Property Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (propertyName.isNotEmpty && !widget.node.properties.value.containsKey(propertyName)) {
                  final properties = Map<String, dynamic>.from(widget.node.properties.value);
                  properties[propertyName] = '';
                  widget.node.properties.value = properties;
                  _propertyControllers[propertyName] = TextEditingController();
                  widget.onPropertyChanged();
                  setState(() {});
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeCustomProperty(String key) {
    final properties = Map<String, dynamic>.from(widget.node.properties.value);
    properties.remove(key);
    widget.node.properties.value = properties;
    _propertyControllers[key]?.dispose();
    _propertyControllers.remove(key);
    widget.onPropertyChanged();
    setState(() {});
  }

  bool _isReservedProperty(String key) {
    const reservedKeys = [
      'field', 'operator', 'value', 'actionType', 'endpoint', 'method', 'delay',
      'outputFormat', 'destination', 'template'
    ];
    return reservedKeys.contains(key);
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Node'),
          content: Text('Are you sure you want to delete node "${widget.node.id}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onDelete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() {
    widget.onPropertyChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  IconData _getNodeIcon(NodeType type) {
    switch (type) {
      case NodeType.condition:
        return Icons.help_outline;
      case NodeType.action:
        return Icons.play_arrow;
      case NodeType.output:
        return Icons.output;
    }
  }

  Color _getNodeColor(NodeType type) {
    switch (type) {
      case NodeType.condition:
        return Colors.blue;
      case NodeType.action:
        return Colors.green;
      case NodeType.output:
        return Colors.orange;
    }
  }
}