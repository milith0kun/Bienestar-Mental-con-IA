import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _notificationsEnabled = true;
  bool _meditationReminders = false;
  bool _journalReminders = true;
  bool _moodReminders = true;
  bool _weeklyReports = true;

  TimeOfDay _meditationTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _journalTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _moodTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final authProvider = context.read<AuthProvider>();
    final prefs = authProvider.user?.preferences;

    if (prefs != null) {
      setState(() {
        _notificationsEnabled = prefs['notificationsEnabled'] ?? true;
        _meditationReminders = prefs['meditationReminders'] ?? false;
        _journalReminders = prefs['journalReminders'] ?? true;
        _moodReminders = prefs['moodReminders'] ?? true;
        _weeklyReports = prefs['weeklyReports'] ?? true;
      });
    }
  }

  Future<void> _savePreferences() async {
    try {
      await context.read<AuthProvider>().updatePreferences({
        'notificationsEnabled': _notificationsEnabled,
        'meditationReminders': _meditationReminders,
        'journalReminders': _journalReminders,
        'moodReminders': _moodReminders,
        'weeklyReports': _weeklyReports,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferencias guardadas'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
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

  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay initialTime,
    Function(TimeOfDay) onTimeSelected,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        onTimeSelected(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePreferences,
            tooltip: 'Guardar cambios',
          ),
        ],
      ),
      body: ListView(
        children: [
          // Main toggle
          SwitchListTile(
            title: const Text(
              'Notificaciones',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Habilitar o deshabilitar todas las notificaciones',
            ),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          const Divider(),

          if (_notificationsEnabled) ...[
            // Meditation reminders
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Recordatorios',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SwitchListTile(
              title: const Text('Recordatorio de meditación'),
              subtitle: Text(
                _meditationReminders
                    ? 'Diariamente a las ${_meditationTime.format(context)}'
                    : 'Desactivado',
              ),
              value: _meditationReminders,
              onChanged: (value) {
                setState(() => _meditationReminders = value);
              },
              secondary: const Icon(Icons.self_improvement),
            ),
            if (_meditationReminders)
              ListTile(
                title: const Text('Hora del recordatorio'),
                trailing: TextButton(
                  onPressed: () => _selectTime(
                    context,
                    _meditationTime,
                    (time) => _meditationTime = time,
                  ),
                  child: Text(
                    _meditationTime.format(context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.only(left: 72, right: 16),
              ),

            const Divider(),

            SwitchListTile(
              title: const Text('Recordatorio de diario'),
              subtitle: Text(
                _journalReminders
                    ? 'Diariamente a las ${_journalTime.format(context)}'
                    : 'Desactivado',
              ),
              value: _journalReminders,
              onChanged: (value) {
                setState(() => _journalReminders = value);
              },
              secondary: const Icon(Icons.book),
            ),
            if (_journalReminders)
              ListTile(
                title: const Text('Hora del recordatorio'),
                trailing: TextButton(
                  onPressed: () => _selectTime(
                    context,
                    _journalTime,
                    (time) => _journalTime = time,
                  ),
                  child: Text(
                    _journalTime.format(context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.only(left: 72, right: 16),
              ),

            const Divider(),

            SwitchListTile(
              title: const Text('Recordatorio de estado de ánimo'),
              subtitle: Text(
                _moodReminders
                    ? 'Diariamente a las ${_moodTime.format(context)}'
                    : 'Desactivado',
              ),
              value: _moodReminders,
              onChanged: (value) {
                setState(() => _moodReminders = value);
              },
              secondary: const Icon(Icons.sentiment_satisfied),
            ),
            if (_moodReminders)
              ListTile(
                title: const Text('Hora del recordatorio'),
                trailing: TextButton(
                  onPressed: () => _selectTime(
                    context,
                    _moodTime,
                    (time) => _moodTime = time,
                  ),
                  child: Text(
                    _moodTime.format(context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.only(left: 72, right: 16),
              ),

            const Divider(),

            // Reports
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Informes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SwitchListTile(
              title: const Text('Resumen semanal'),
              subtitle: const Text(
                'Recibe un resumen de tu progreso cada semana',
              ),
              value: _weeklyReports,
              onChanged: (value) {
                setState(() => _weeklyReports = value);
              },
              secondary: const Icon(Icons.bar_chart),
            ),

            const SizedBox(height: 24),

            // Info card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Los recordatorios te ayudan a mantener una práctica constante de bienestar mental',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Notificaciones desactivadas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Activa las notificaciones para recibir recordatorios diarios',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
