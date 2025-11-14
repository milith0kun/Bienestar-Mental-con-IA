import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/meditation_provider.dart';
import '../../widgets/stats_card_widget.dart';
import '../../widgets/mood_chart_widget.dart';
import '../../widgets/loading_widget.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    _loadAllStats();
  }

  Future<void> _loadAllStats() async {
    final moodProvider = context.read<MoodProvider>();
    final journalProvider = context.read<JournalProvider>();

    await Future.wait([
      moodProvider.loadStats(),
      moodProvider.loadLogs(),
      journalProvider.loadStats(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadAllStats,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Text(
              'Tus Estadísticas',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Visualiza tu progreso y bienestar',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 24),

            // Mood stats
            _MoodStatsSection(),

            const SizedBox(height: 24),

            // Journal stats
            _JournalStatsSection(),

            const SizedBox(height: 24),

            // Meditation stats (placeholder)
            Text(
              'Meditaciones',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.self_improvement,
                      size: 48,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Comienza a meditar',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tus estadísticas de meditación aparecerán aquí',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/meditations');
                      },
                      child: const Text('Explorar meditaciones'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _MoodStatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SizedBox(
            height: 200,
            child: LoadingWidget(message: 'Cargando estadísticas...'),
          );
        }

        if (provider.stats == null || provider.stats!.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.insert_chart,
                    size: 48,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sin datos de ánimo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registra tu estado de ánimo para ver tus estadísticas',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/mood-log');
                    },
                    child: const Text('Registrar ahora'),
                  ),
                ],
              ),
            ),
          );
        }

        final stats = provider.stats!;
        final chartData = provider.logs
            .take(7)
            .map((log) => MoodChartData(
                  date: log.date,
                  moodValue: log.moodValue,
                  notes: log.notes,
                ))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estado de Ánimo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/mood-history');
                  },
                  child: const Text('Ver todo'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stats cards
            Row(
              children: [
                Expanded(
                  child: StatsCardWidget(
                    title: 'Racha actual',
                    value: '${stats['currentStreak'] ?? 0}',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                    subtitle: 'días consecutivos',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCardWidget(
                    title: 'Total registros',
                    value: '${stats['totalLogs'] ?? 0}',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Chart
            if (chartData.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Últimos 7 días',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      MoodChartWidget(
                        data: chartData,
                        period: 'week',
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _JournalStatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<JournalProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SizedBox(
            height: 150,
            child: LoadingWidget(message: 'Cargando diario...'),
          );
        }

        if (provider.stats == null || provider.stats!.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.book,
                    size: 48,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sin entradas en el diario',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escribe tu primera entrada para ver tus estadísticas',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/journal-create');
                    },
                    child: const Text('Escribir entrada'),
                  ),
                ],
              ),
            ),
          );
        }

        final stats = provider.stats!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Diario Emocional',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/journal');
                  },
                  child: const Text('Ver todo'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatsCardWidget(
                    title: 'Total entradas',
                    value: '${stats['totalEntries'] ?? 0}',
                    icon: Icons.edit_note,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCardWidget(
                    title: 'Este mes',
                    value: '${stats['entriesThisMonth'] ?? 0}',
                    icon: Icons.calendar_month,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
