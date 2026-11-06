import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../utils/dates.dart';
import 'task_detail_screen.dart';

/// Écran principal : les échéances, les cours et le profil, avec une
/// NavigationBar en bas pour passer de l'un à l'autre.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.repository = const CampusRepository()});

  final CampusRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  bool _loading = true;

  User? _user;
  List<Course> _courses = [];
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Les deux appels partent en même temps.
    final userFuture = widget.repository.fetchUser();
    final coursesFuture = widget.repository.fetchCourses();
    final user = await userFuture;
    final courses = await coursesFuture;

    if (!mounted) return;
    setState(() {
      _user = user;
      _courses = courses;
      _tasks = courses.expand((course) => course.tasks).toList();
      _sortTasks();
      _loading = false;
    });
  }

  // La plus proche échéance en premier.
  void _sortTasks() {
    _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  String _courseTitle(String courseId) {
    final course = _courses.where((c) => c.id == courseId).firstOrNull;
    return course?.title ?? 'Cours inconnu';
  }

  // Remplace l'ancienne version de la tâche (même id) par la nouvelle.
  void _updateTask(Task updated) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == updated.id);
      _tasks[index] = updated;
    });
  }

  void _openTask(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          task: task,
          courseTitle: _courseTitle(task.courseId),
          onChanged: _updateTask,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Mes échéances', 'Mes cours', 'Mon profil'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_currentTab])),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : switch (_currentTab) {
              0 => _buildTaskList(),
              1 => _buildCourseList(),
              _ => _buildProfile(),
            },
      floatingActionButton: _currentTab == 0 && !_loading
          ? FloatingActionButton(
              onPressed: () {},
              tooltip: 'Nouvelle tâche',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (index) => setState(() => _currentTab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Échéances',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Cours',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    if (_tasks.isEmpty) {
      return const Center(child: Text('Rien à rendre pour le moment.'));
    }

    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        final late = !task.done && daysLeft(task.dueDate) < 0;

        return ListTile(
          leading: Icon(
            task.done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: task.done ? Colors.green : null,
          ),
          title: Text(
            task.title,
            style: task.done
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null,
          ),
          subtitle: Text(
            '${_courseTitle(task.courseId)} · ${relativeDueDate(task.dueDate)}',
            style: late
                ? TextStyle(color: Theme.of(context).colorScheme.error)
                : null,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openTask(task),
        );
      },
    );
  }

  Widget _buildCourseList() {
    return ListView.builder(
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        final count = _tasks.where((t) => t.courseId == course.id).length;

        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.book_outlined)),
          title: Text(course.title),
          subtitle: Text(course.teacher),
          trailing: Text('$count tâche${count > 1 ? 's' : ''}'),
        );
      },
    );
  }

  Widget _buildProfile() {
    final user = _user!;
    final done = _tasks.where((t) => t.done).length;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            child: Text(
              user.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(height: 16),
          Text(user.name, style: Theme.of(context).textTheme.titleLarge),
          Text(user.email),
          const SizedBox(height: 24),
          Text('$done / ${_tasks.length} tâches terminées'),
        ],
      ),
    );
  }
}
