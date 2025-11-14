import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/mood_provider.dart';
import '../../widgets/mood_chart_widget.dart';
import '../../widgets/stats_card_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../../data/models/mood_log_model.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().loadLogs();
      context.read<MoodProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ánimo'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'week',
                child: Text('Última semana'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('Último mes'),
              ),
              const PopupMenuItem(
                value: 'year',
                child: Text('Último año'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<MoodProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.logs.isEmpty) {
            return const LoadingWidget(message: 'Cargando historial...');
          }

          if (provider.error != null && provider.logs.isEmpty) {
            return CustomErrorWidget(
              message: provider.error!,
              onRetry: () {
                provider.loadLogs();
                provider.loadStats();
              },
            );
          }

          if (provider.logs.isEmpty) {
            return EmptyState(
              icon: Icons.insert_chart,
              title: 'Sin registros',
              message:
                  'Comienza a registrar tu estado de ánimo diario para ver tus estadísticas',
              actionLabel: 'Registrar ahora',
              onActionPressed: () {
                Navigator.pushNamed(context, '/mood-log');
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadLogs();
              await provider.loadStats();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Stats cards
                if (provider.stats != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: StatsCardWidget(
                          title: 'Promedio',
                          value: _getMoodLabel(
                            provider.stats!['averageMood']?.round() ?? 3,
                          ),
                          icon: Icons.sentiment_satisfied,
                          color: _getMoodColor(
                            provider.stats!['averageMood']?.round() ?? 3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCardWidget(
                          title: 'Total registros',
                          value: '${provider.stats!['totalLogs'] ?? 0}',
                          icon: Icons.calendar_today,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCardWidget(
                          title: 'Racha actual',
                          value: '${provider.stats!['currentStreak'] ?? 0} días',
                          icon: Icons.local_fire_department,
                          color: Colors.orange,
                          subtitle: 'Sigue así!',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCardWidget(
                          title: 'Mejor racha',
                          value: '${provider.stats!['longestStreak'] ?? 0} días',
                          icon: Icons.emoji_events,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Chart
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tendencia de ánimo',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getPeriodLabel(),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                        ),
                        const SizedBox(height: 16),
                        MoodChartWidget(
                          data: _getChartData(provider.logs),
                          period: _selectedPeriod,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // History list
                Text(
                  'Historial detallado',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                ...provider.logs.take(10).map((log) => _MoodLogCard(log: log)),

                if (provider.logs.length > 10) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // TODO: Navigate to full history
                      },
                      child: const Text('Ver todo el historial'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/mood-log');
        },
        child: const Icon(Icons.add),
        tooltip: 'Registrar ánimo',
      ),
    );
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'week':
        return 'Últimos 7 días';
      case 'month':
        return 'Últimos 30 días';
      case 'year':
        return 'Últimos 12 meses';
      default:
        return 'Período';
    }
  }

  List<MoodChartData> _getChartData(List<MoodLogModel> logs) {
    int days;
    switch (_selectedPeriod) {
      case 'week':
        days = 7;
        break;
      case 'month':
        days = 30;
        break;
      case 'year':
        days = 365;
        break;
      default:
        days = 7;
    }

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final filteredLogs = logs
        .where((log) => log.date.isAfter(startDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return filteredLogs
        .map((log) => MoodChartData(
              date: log.date,
              moodValue: log.moodValue,
              notes: log.notes,
            ))
        .toList();
  }

  String _getMoodLabel(int value) {
    const labels = ['', 'Muy mal', 'Mal', 'Neutral', 'Bien', 'Muy bien'];
    if (value < 1 || value > 5) return 'Neutral';
    return labels[value];
  }

  Color _getMoodColor(int value) {
    const colors = [
      Colors.grey,
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.lightGreen,
      Colors.green,
    ];
    if (value < 1 || value > 5) return Colors.grey;
    return colors[value];
  }
}

class _MoodLogCard extends StatelessWidget {
  final MoodLogModel log;

  const _MoodLogCard({required this.log});

  Color _getMoodColor(int value) {
    const colors = [
      Colors.grey,
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.lightGreen,
      Colors.green,
    ];
    if (value < 1 || value > 5) return Colors.grey;
    return colors[value];
  }

  IconData _getMoodIcon(int value) {
    const icons = [
      Icons.circle,
      Icons.sentiment_very_dissatisfied,
      Icons.sentiment_dissatisfied,
      Icons.sentiment_neutral,
      Icons.sentiment_satisfied,
      Icons.sentiment_very_satisfied,
    ];
    if (value < 1 || value > 5) return Icons.circle;
    return icons[value];
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es');
    final timeFormat = DateFormat('HH:mm', 'es');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Mood indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getMoodColor(log.moodValue).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getMoodIcon(log.moodValue),
                color: _getMoodColor(log.moodValue),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.mood ?? 'Sin especificar',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(log.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  Text(
                    timeFormat.format(log.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                        ),
                  ),
                  if (log.notes != null && log.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      log.notes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
