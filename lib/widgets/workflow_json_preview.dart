import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workflow_node.dart';
import '../utils/json_generator.dart';

class WorkflowJsonPreview extends StatefulWidget {
  final WorkflowNode? rootNode;
  final VoidCallback onClose;
  final Function(String)? onJsonChanged;

  const WorkflowJsonPreview({
    super.key,
    required this.rootNode,
    required this.onClose,
    this.onJsonChanged,
  });

  @override
  State<WorkflowJsonPreview> createState() => _WorkflowJsonPreviewState();
}

class _WorkflowJsonPreviewState extends State<WorkflowJsonPreview>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _jsonString = '';
  List<ValidationError> _validationErrors = [];
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateJson();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateJson() {
    if (widget.rootNode == null) {
      _jsonString = '{}';
      _validationErrors = [];
      _isValid = false;
      return;
    }

    try {
      _jsonString = JsonGenerator.generateWorkflowJson(widget.rootNode!);
      _validationErrors = JsonGenerator.validateWorkflow(widget.rootNode!);
      _isValid = _validationErrors.isEmpty;
      widget.onJsonChanged?.call(_jsonString);
    } catch (e) {
      _jsonString = 'Error generating JSON: $e';
      _isValid = false;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(WorkflowJsonPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rootNode != widget.rootNode) {
      _generateJson();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJsonTab(),
                _buildValidationTab(),
              ],
            ),
          ),
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
            Icons.code,
            color: _isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Workflow JSON',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          if (_validationErrors.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_validationErrors.length} errors',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.content_copy),
            onPressed: _isValid ? _copyToClipboard : null,
            tooltip: 'Copy JSON',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateJson,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: const [
          Tab(text: 'JSON'),
          Tab(text: 'Validation'),
        ],
      ),
    );
  }

  Widget _buildJsonTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isValid ? Icons.check_circle : Icons.error,
                color: _isValid ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _isValid ? 'Valid JSON' : 'Invalid JSON',
                style: TextStyle(
                  color: _isValid ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _jsonString,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _validationErrors.isEmpty ? Icons.check_circle : Icons.warning,
                color: _validationErrors.isEmpty ? Colors.green : Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _validationErrors.isEmpty
                    ? 'No validation errors'
                    : '${_validationErrors.length} validation errors found',
                style: TextStyle(
                  color: _validationErrors.isEmpty ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _validationErrors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.green.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Workflow is valid!',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.green.shade700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your workflow has no validation errors and is ready to be executed.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _validationErrors.length,
                    itemBuilder: (context, index) {
                      final error = _validationErrors[index];
                      return _buildErrorItem(error);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorItem(ValidationError error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade700,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Node: ${error.nodeId}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            error.message,
            style: TextStyle(
              color: Colors.red.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Type: ${error.type.name}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard() {
    if (_isValid) {
      Clipboard.setData(ClipboardData(text: _jsonString));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('JSON copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
