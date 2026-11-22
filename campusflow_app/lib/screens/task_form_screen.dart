import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/dates.dart';

/// Formulaire de création d'une tâche. Renvoie la nouvelle [Task] avec
/// `Navigator.pop`, ou rien si l'utilisateur revient en arrière.
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, required this.courses});

  final List<Course> courses;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  String? _courseId;
  // Par défaut, à rendre demain (puce présélectionnée dans le wireframe).
  DateTime _dueDate = _inDays(1);

  /// Raccourcis de date du wireframe 04 : « ajout en 3 appuis » (parcours,
  /// étape 3). Nombre de jours à partir d'aujourd'hui → libellé de la puce.
  static const _shortcuts = {0: "Aujourd'hui", 1: 'Demain', 3: 'Dans 3 jours'};

  /// Date dans [days] jours, à 18 h (heure de rendu habituelle).
  static DateTime _inDays(int days) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + days, 18);
  }

  void _setDueDate(DateTime date) {
    setState(() {
      _dueDate = date;
      _dateController.text = formatDate(_dueDate);
    });
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = formatDate(_dueDate);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked == null) return;

    // On fixe l'heure de rendu à 18h, comme pour les autres tâches.
    _setDueDate(DateTime(picked.year, picked.month, picked.day, 18));
  }

  void _save() {
    // Lance tous les validator ; s'il y a une erreur, elle s'affiche sous
    // le champ concerné et on s'arrête là.
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      id: 't${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      courseId: _courseId!,
    );
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle tâche')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre (obligatoire)',
                  hintText: 'Ex. Rapport projet réseaux',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Le titre est obligatoire';
                  if (text.length < 3) return 'Au moins 3 caractères';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.m),
              DropdownButtonFormField<String>(
                initialValue: _courseId,
                decoration: const InputDecoration(labelText: 'Cours'),
                items: [
                  for (final course in widget.courses)
                    DropdownMenuItem(
                      value: course.id,
                      child: Text(course.title),
                    ),
                ],
                onChanged: (value) => setState(() => _courseId = value),
                validator: (value) => value == null ? 'Choisis un cours' : null,
              ),
              const SizedBox(height: AppSpacing.m),
              // Raccourcis de date. Wrap (et non Row) : les puces passent à
              // la ligne si la place manque (texte agrandi), sans débordement.
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: [
                  for (final MapEntry(key: days, value: label)
                      in _shortcuts.entries)
                    ChoiceChip(
                      label: Text(label),
                      selected: daysLeft(_dueDate) == days,
                      onSelected: (_) => _setDueDate(_inDays(days)),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'À rendre le',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (facultatif)',
                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: 6,
              ),
              const SizedBox(height: AppSpacing.l),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
