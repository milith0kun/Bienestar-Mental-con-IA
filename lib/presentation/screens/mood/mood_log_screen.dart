import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mood_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../data/models/mood_log_model.dart';

class MoodLogScreen extends StatefulWidget {
  const MoodLogScreen({super.key});

  @override
  State<MoodLogScreen> createState() => _MoodLogScreenState();
}

class _MoodLogScreenState extends State<MoodLogScreen> {
  String? _selectedMood;
  int _selectedMoodValue = 3;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _moods = [
    {
      'value': 1,
      'label': 'Muy mal',
      'icon': Icons.sentiment_very_dissatisfied,
      'color': Colors.red,
    },
    {
      'value': 2,
      'label': 'Mal',
      'icon': Icons.sentiment_dissatisfied,
      'color': Colors.orange,
    },
    {
      'value': 3,
      'label': 'Neutral',
      'icon': Icons.sentiment_neutral,
      'color': Colors.yellow,
    },
    {
      'value': 4,
      'label': 'Bien',
      'icon': Icons.sentiment_satisfied,
      'color': Colors.lightGreen,
    },
    {
      'value': 5,
      'label': 'Muy bien',
      'icon': Icons.sentiment_very_satisfied,
      'color': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTodayLog();
    });
  }

  Future<void> _checkTodayLog() async {
    final provider = context.read<MoodProvider>();
    await provider.loadTodayLog();

    if (provider.todayLog != null) {
      final todayLog = provider.todayLog!;
      setState(() {
        _selectedMoodValue = todayLog.moodValue;
        _selectedMood = todayLog.mood;
        _notesController.text = todayLog.notes ?? '';
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMoodLog() async {
    setState(() => _isLoading = true);

    try {
      final log = MoodLogModel(
        id: context.read<MoodProvider>().todayLog?.id,
        userId: '',
        mood: _selectedMood ?? _moods[_selectedMoodValue - 1]['label'],
        moodValue: _selectedMoodValue,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        date: DateTime.now(),
      );

      await context.read<MoodProvider>().logMood(log);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estado de ánimo registrado'),
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
            content: Text('Error al registrar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMoodData = _moods[_selectedMoodValue - 1];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar estado de ánimo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Text(
                  '¿Cómo te sientes hoy?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Mood icon display
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: (selectedMoodData['color'] as Color).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    selectedMoodData['icon'] as IconData,
                    size: 80,
                    color: selectedMoodData['color'] as Color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  selectedMoodData['label'],
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: selectedMoodData['color'] as Color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Mood slider
          Text(
            'Desliza para seleccionar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              activeTrackColor: selectedMoodData['color'] as Color,
              thumbColor: selectedMoodData['color'] as Color,
              overlayColor:
                  (selectedMoodData['color'] as Color).withOpacity(0.3),
            ),
            child: Slider(
              value: _selectedMoodValue.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (value) {
                setState(() {
                  _selectedMoodValue = value.toInt();
                  _selectedMood = null;
                });
              },
            ),
          ),

          const SizedBox(height: 8),

          // Mood labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Muy mal',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Muy bien',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),

          const SizedBox(height: 48),

          // Quick mood buttons
          Text(
            'O selecciona directamente',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _moods.map((mood) {
              final isSelected = _selectedMoodValue == mood['value'];
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedMoodValue = mood['value'] as int;
                    _selectedMood = mood['label'] as String;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (mood['color'] as Color).withOpacity(0.2)
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? mood['color'] as Color
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        mood['icon'] as IconData,
                        color: mood['color'] as Color,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        mood['label'] as String,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 48),

          // Notes
          Text(
            'Notas (opcional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _notesController,
            hint: '¿Qué te hace sentir así?',
            maxLines: 4,
          ),

          const SizedBox(height: 48),

          // Save button
          CustomButton(
            text: context.watch<MoodProvider>().todayLog != null
                ? 'Actualizar registro'
                : 'Guardar registro',
            onPressed: _saveMoodLog,
            isLoading: _isLoading,
            width: double.infinity,
            icon: Icons.check,
          ),

          if (context.watch<MoodProvider>().todayLog != null) ...[
            const SizedBox(height: 16),
            Text(
              'Ya registraste tu estado de ánimo hoy. Puedes actualizarlo si lo deseas.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
