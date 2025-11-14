import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/journal_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../../data/models/journal_entry_model.dart';

class JournalEditScreen extends StatefulWidget {
  final String? entryId;

  const JournalEditScreen({
    super.key,
    this.entryId,
  });

  @override
  State<JournalEditScreen> createState() => _JournalEditScreenState();
}

class _JournalEditScreenState extends State<JournalEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();

  String? _selectedMood;
  List<String> _tags = [];
  bool _isLoading = false;
  bool _aiAnalyzing = false;
  String? _aiInsights;
  JournalEntryModel? _existingEntry;

  final List<String> _moods = [
    'Muy bien',
    'Bien',
    'Neutral',
    'Triste',
    'Muy triste',
  ];

  final Map<String, IconData> _moodIcons = {
    'Muy bien': Icons.sentiment_very_satisfied,
    'Bien': Icons.sentiment_satisfied,
    'Neutral': Icons.sentiment_neutral,
    'Triste': Icons.sentiment_dissatisfied,
    'Muy triste': Icons.sentiment_very_dissatisfied,
  };

  final Map<String, Color> _moodColors = {
    'Muy bien': Colors.green,
    'Bien': Colors.lightGreen,
    'Neutral': Colors.yellow,
    'Triste': Colors.orange,
    'Muy triste': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    if (widget.entryId != null) {
      _loadEntry();
    }
  }

  Future<void> _loadEntry() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<JournalProvider>();
      final entry = provider.entries.firstWhere(
        (e) => e.id == widget.entryId,
        orElse: () => throw Exception('Entrada no encontrada'),
      );

      setState(() {
        _existingEntry = entry;
        _contentController.text = entry.content;
        _selectedMood = entry.mood;
        _tags = entry.tags ?? [];
        _aiInsights = entry.aiInsights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar entrada: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  Future<void> _analyzeWithAI() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe algo primero para analizar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _aiAnalyzing = true);

    try {
      final insights = await context
          .read<JournalProvider>()
          .getAIInsights(_contentController.text);

      setState(() {
        _aiInsights = insights;
        _aiAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Análisis completado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _aiAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en análisis: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final entry = JournalEntryModel(
        id: _existingEntry?.id,
        userId: _existingEntry?.userId ?? '',
        content: _contentController.text.trim(),
        mood: _selectedMood,
        tags: _tags.isEmpty ? null : _tags,
        aiInsights: _aiInsights,
        createdAt: _existingEntry?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_existingEntry != null) {
        await context.read<JournalProvider>().updateEntry(entry);
      } else {
        await context.read<JournalProvider>().createEntry(entry);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _existingEntry != null
                  ? 'Entrada actualizada'
                  : 'Entrada creada',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _existingEntry == null) {
      return const Scaffold(
        body: LoadingWidget(message: 'Cargando...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entryId != null ? 'Editar entrada' : 'Nueva entrada',
        ),
        actions: [
          if (!_aiAnalyzing)
            IconButton(
              icon: const Icon(Icons.psychology),
              onPressed: _analyzeWithAI,
              tooltip: 'Analizar con IA',
            ),
          if (_aiAnalyzing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Mood selector
            Text(
              '¿Cómo te sientes?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _moodIcons[mood],
                        size: 20,
                        color: isSelected
                            ? Colors.white
                            : _moodColors[mood]!,
                      ),
                      const SizedBox(width: 8),
                      Text(mood),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: _moodColors[mood],
                  onSelected: (selected) {
                    setState(() => _selectedMood = selected ? mood : null);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Content
            Text(
              'Escribe tus pensamientos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _contentController,
              hint: 'Hoy me siento...',
              maxLines: 10,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor escribe algo';
                }
                if (value.trim().length < 10) {
                  return 'Escribe al menos 10 caracteres';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // AI Insights
            if (_aiInsights != null) ...[
              Text(
                'Análisis de IA',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.psychology,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _aiInsights!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Tags
            Text(
              'Etiquetas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _tagController,
                    hint: 'Agregar etiqueta...',
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text('#$tag'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeTag(tag),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 40),

            // Save button
            CustomButton(
              text: widget.entryId != null
                  ? 'Actualizar entrada'
                  : 'Guardar entrada',
              onPressed: _saveEntry,
              isLoading: _isLoading,
              width: double.infinity,
              icon: Icons.save,
            ),
          ],
        ),
      ),
    );
  }
}
