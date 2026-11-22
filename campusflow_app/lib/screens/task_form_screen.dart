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
  // Par défaut, à rendre dans une semaine.
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

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

    setState(() {
      // On fixe l'heure de rendu à 18h, comme pour les autres tâches.
      _dueDate = DateTime(picked.year, picked.month, picked.day, 18);
      _dateController.text = formatDate(_dueDate);
    });
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
                  labelText: 'Titre',
                  hintText: 'Ex. : Rapport de TP',
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
