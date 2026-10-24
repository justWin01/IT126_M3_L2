import 'package:flutter/material.dart';

/// Activity section: intentionally uses only an in-memory List<String>.
/// Entries disappear after the application process ends.
class MemoryActivityScreen extends StatefulWidget {
  const MemoryActivityScreen({super.key});

  @override
  State<MemoryActivityScreen> createState() => _MemoryActivityScreenState();
}

class _MemoryActivityScreenState extends State<MemoryActivityScreen> {
  final _controller = TextEditingController();
  final List<String> _tasks = [];

  void _addTask() {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a task title first.')),
      );
      return;
    }

    setState(() {
      _tasks.add(title);
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity: In-memory tasks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'This tab stores tasks in a Dart List only. '
            'Restart the app to observe that these tasks are not saved.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addTask(),
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _addTask,
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Tasks in memory: ${_tasks.length}'),
          const SizedBox(height: 8),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('No in-memory tasks yet.'))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) => Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(_tasks[index]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
