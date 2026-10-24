import 'package:flutter/material.dart';
import 'data/task_repository.dart';
import 'screens/memory_activity_screen.dart';
import 'screens/task_manager_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskLessonApp());
}

class TaskLessonApp extends StatelessWidget {
  const TaskLessonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IT 126 Local Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<TaskRepository> _repositoryFuture;

  @override
  void initState() {
    super.initState();
    _repositoryFuture = TaskRepository.create();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TaskRepository>(
      future: _repositoryFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('IT 126 Module 3 Lesson 2')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'The local database could not be opened.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Local Task Manager'),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.memory), text: 'Activity'),
                  Tab(icon: Icon(Icons.storage), text: 'SQLite App'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                const MemoryActivityScreen(),
                TaskManagerScreen(repository: snapshot.data!),
              ],
            ),
          ),
        );
      },
    );
  }
}
