import 'package:flutter/material.dart';
import '../data/task_repository.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key, required this.repository});

  final TaskRepository repository;

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  final _controller = TextEditingController();
  late Future<List<Task>> _tasksFuture;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tasksFuture = widget.repository.getAllTasks();
  }

  void _reloadTasks() {
    setState(() {
      _tasksFuture = widget.repository.getAllTasks();
    });
  }

  Future<void> _addTask() async {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task title cannot be empty.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.repository.createTask(title);
      _controller.clear();
      _reloadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task saved to SQLite.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save task: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _toggleTask(Task task, bool? value) async {
    try {
      await widget.repository.setCompleted(task.id, value ?? false);
      _reloadTasks();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update task: $error')),
        );
      }
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      await widget.repository.deleteTask(task.id);
      _reloadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted from SQLite.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete task: $error')),
        );
      }
    }
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
            'Application: SQLite Task Manager',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tasks saved here remain available after closing and reopening '
            'the app. Database operations are handled by TaskRepository.',
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
                    hintText: 'e.g. Complete Module 3',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _isSaving ? null : _addTask,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Could not load tasks: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data!;
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text('No saved tasks. Add your first task above.'),
                  );
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) => _toggleTask(task, value),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          task.isCompleted ? 'Completed' : 'Pending',
                        ),
                        trailing: IconButton(
                          tooltip: 'Delete task',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteTask(task),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
