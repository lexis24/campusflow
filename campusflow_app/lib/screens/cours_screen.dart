import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/taches_provider.dart';

/// Écran Cours, adresse /cours (destination 2 de la NavigationBar).
class CoursScreen extends ConsumerWidget {
  const CoursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cours = ref.watch(coursProvider);
    final taches = ref.watch(tachesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes cours')),
      body: ListView.builder(
        itemCount: cours.length,
        itemBuilder: (context, index) {
          final course = cours[index];
          final nombre = taches.where((t) => t.courseId == course.id).length;

          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.book_outlined)),
            title: Text(course.title),
            subtitle: Text(course.teacher),
            trailing: Text('$nombre tâche${nombre > 1 ? 's' : ''}'),
          );
        },
      ),
    );
  }
}
