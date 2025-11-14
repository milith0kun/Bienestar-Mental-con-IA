import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/journal_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_card.dart';
import '../../../data/models/journal_entry_model.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalProvider>().loadEntries();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<JournalProvider>().loadMoreEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diario Emocional'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/journal-stats');
            },
            tooltip: 'Estadísticas',
          ),
        ],
      ),
      body: Consumer<JournalProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.entries.isEmpty) {
            return const LoadingWidget(message: 'Cargando entradas...');
          }

          if (provider.error != null && provider.entries.isEmpty) {
            return CustomErrorWidget(
              message: provider.error!,
              onRetry: () => provider.loadEntries(),
            );
          }

          if (provider.entries.isEmpty) {
            return EmptyState(
              icon: Icons.book,
              title: 'Sin entradas',
              message:
                  'Comienza a escribir tus pensamientos y emociones en tu diario personal',
              actionLabel: 'Crear primera entrada',
              onActionPressed: () {
                Navigator.pushNamed(context, '/journal-create');
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadEntries(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.entries.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= provider.entries.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final entry = provider.entries[index];
                return _JournalEntryCard(
                  entry: entry,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/journal-detail',
                      arguments: entry.id,
                    );
                  },
                  onDelete: () => _confirmDelete(context, entry.id!),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/journal-create');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva entrada'),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String entryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar entrada'),
        content:
            const Text('¿Estás seguro de que quieres eliminar esta entrada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<JournalProvider>().deleteEntry(entryId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entrada eliminada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _JournalEntryCard extends StatelessWidget {
  final JournalEntryModel entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _JournalEntryCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  Color _getMoodColor(String? mood) {
    switch (mood?.toLowerCase()) {
      case 'feliz':
      case 'muy bien':
        return Colors.green;
      case 'bien':
        return Colors.lightGreen;
      case 'neutral':
        return Colors.yellow;
      case 'triste':
        return Colors.orange;
      case 'muy triste':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getMoodIcon(String? mood) {
    switch (mood?.toLowerCase()) {
      case 'feliz':
      case 'muy bien':
        return Icons.sentiment_very_satisfied;
      case 'bien':
        return Icons.sentiment_satisfied;
      case 'neutral':
        return Icons.sentiment_neutral;
      case 'triste':
        return Icons.sentiment_dissatisfied;
      case 'muy triste':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy, HH:mm', 'es');

    return CustomCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Mood indicator
              if (entry.mood != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getMoodColor(entry.mood).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getMoodIcon(entry.mood),
                    color: _getMoodColor(entry.mood),
                    size: 24,
                  ),
                ),
              const SizedBox(width: 12),

              // Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(entry.createdAt),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (entry.mood != null)
                      Text(
                        entry.mood!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getMoodColor(entry.mood),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                color: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content preview
          Text(
            entry.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          // AI insights preview
          if (entry.aiInsights != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.aiInsights!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Tags
          if (entry.tags != null && entry.tags!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.tags!.take(3).map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
