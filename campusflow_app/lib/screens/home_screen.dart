import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/dates.dart';
import '../utils/periodes.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

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

  /// Tâche affichée à droite de la liste en mode tablette.
  String? _selectedTaskId;

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

  Future<void> _addTask() async {
    final newTask = await Navigator.of(context).push<Task>(
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(courses: _courses),
        // Écran de saisie : bouton × « Fermer » au lieu de la flèche retour.
        fullscreenDialog: true,
      ),
    );
    // null si l'utilisateur a fait retour sans enregistrer.
    if (newTask == null || !mounted) return;

    setState(() {
      _tasks.add(newTask);
      _sortTasks();
      _selectedTaskId = newTask.id;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('« ${newTask.title} » ajoutée')));
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
              onPressed: _addTask,
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

  /// Sur téléphone : juste la liste. À partir de 840 dp (tablette, grand
  /// écran) : la liste à gauche et le détail de la tâche choisie à droite.
  Widget _buildTaskList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= AppSizes.tabletBreakpoint;
        if (!wide) return _buildTaskListView(wide: false);

        final selected = _tasks
            .where((t) => t.id == _selectedTaskId)
            .firstOrNull;
        return Row(
          children: [
            SizedBox(
              width: AppSizes.masterPaneWidth,
              child: _buildTaskListView(wide: true),
            ),
            const VerticalDivider(width: AppSizes.hairline),
            Expanded(
              child: selected == null
                  ? const Center(child: Text('Choisis une échéance à gauche.'))
                  : TaskDetailView(
                      task: selected,
                      courseTitle: _courseTitle(selected.courseId),
                      onToggleDone: () =>
                          _updateTask(selected.copyWith(done: !selected.done)),
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Liste des échéances groupée par période (variante B, séance 2).
  Widget _buildTaskListView({required bool wide}) {
    if (_tasks.isEmpty) {
      return const Center(child: Text('Rien à rendre pour le moment.'));
    }

    // Liste « plate » : chaque section donne une ligne d'en-tête suivie de
    // ses tâches. Un seul ListView.builder construit ensuite toutes les
    // lignes, et seulement celles visibles à l'écran.
    final lignes = <_Ligne>[
      for (final MapEntry(key: periode, value: taches) in grouperParPeriode(
        _tasks,
      ).entries) ...[
        _EnTete(periode, taches.length),
        for (final tache in taches) _LigneTache(tache),
      ],
    ];

    return ListView.builder(
      itemCount: lignes.length,
      // Le switch sur une sealed class oblige à traiter les deux cas.
      itemBuilder: (context, index) => switch (lignes[index]) {
        _EnTete(:final periode, :final nombre) => _buildEnTete(periode, nombre),
        _LigneTache(:final task) => _buildTaskTile(task, wide: wide),
      },
    );
  }

  /// En-tête de section, lui aussi un ListTile (« chaque ligne est un
  /// ListTile »). « En retard » prend les couleurs d'erreur du thème,
  /// les autres le fond surfaceContainerHighest (design system § 4.2).
  Widget _buildEnTete(Periode periode, int nombre) {
    final colors = Theme.of(context).colorScheme;
    final enRetard = periode == Periode.enRetard;
    final fond = enRetard ? colors.error : colors.surfaceContainerHighest;
    final texte = enRetard ? colors.onError : colors.onSurface;
    final style = Theme.of(context).textTheme.titleMedium
        ?.copyWith(color: texte);

    // header: true : le lecteur d'écran annonce un titre de section.
    return Semantics(
      header: true,
      child: ListTile(
        dense: true,
        tileColor: fond,
        iconColor: texte,
        leading: enRetard ? const Icon(Icons.error_outline) : null,
        title: Text(periode.libelle, style: style),
        trailing: Text('$nombre', style: style),
      ),
    );
  }

  /// Ligne de tâche (design system § 4.2) : titre, cours en sous-titre,
  /// date courte à droite, en couleur d'erreur si la tâche est en retard.
  Widget _buildTaskTile(Task task, {required bool wide}) {
    final colors = Theme.of(context).colorScheme;
    final late = !task.done && daysLeft(task.dueDate) < 0;

    return ListTile(
      leading: Icon(
        task.done ? Icons.check_circle : Icons.radio_button_unchecked,
        // Couleur du thème (contraste 6,12:1) au lieu de Colors.green
        // en dur (2,64:1, insuffisant) : voir le design system § 1.
        color: task.done ? colors.primary : null,
      ),
      title: Text(
        task.title,
        style: task.done
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(_courseTitle(task.courseId)),
      trailing: Row(
        // min : la Row prend juste la place de la date et du chevron,
        // sinon elle voudrait toute la largeur du trailing.
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            shortDueDate(task.dueDate),
            style: late ? TextStyle(color: colors.error) : null,
          ),
          // Sur tablette, pas de chevron : le détail s'affiche à côté.
          if (!wide) const Icon(Icons.chevron_right),
        ],
      ),
      // Sur tablette, la ligne choisie est surlignée et on reste sur
      // l'écran ; sur téléphone, on ouvre la page de détail.
      selected: wide && task.id == _selectedTaskId,
      onTap: wide
          ? () => setState(() => _selectedTaskId = task.id)
          : () => _openTask(task),
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
            radius: AppSizes.avatarRadius,
            child: Text(
              user.name.substring(0, 1).toUpperCase(),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(user.name, style: Theme.of(context).textTheme.titleLarge),
          Text(user.email),
          const SizedBox(height: AppSpacing.l),
          Text('$done / ${_tasks.length} tâches terminées'),
        ],
      ),
    );
  }
}

/// Une ligne de la liste des échéances : soit un en-tête de section,
/// soit une tâche. « sealed » : il n'existe que ces deux sortes de lignes.
sealed class _Ligne {
  const _Ligne();
}

/// En-tête de section : la période et le nombre de tâches qu'elle contient.
class _EnTete extends _Ligne {
  const _EnTete(this.periode, this.nombre);

  final Periode periode;
  final int nombre;
}

/// Ligne de tâche.
class _LigneTache extends _Ligne {
  const _LigneTache(this.task);

  final Task task;
}
