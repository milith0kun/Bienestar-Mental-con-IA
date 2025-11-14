import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/meditation_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../../data/models/meditation_model.dart';

class MeditationListScreen extends StatefulWidget {
  const MeditationListScreen({super.key});

  @override
  State<MeditationListScreen> createState() => _MeditationListScreenState();
}

class _MeditationListScreenState extends State<MeditationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeditationProvider>().loadMeditations();
      context.read<MeditationProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<MeditationProvider>().applyFilters(
          searchQuery: _searchController.text,
          category: _selectedCategory,
          difficulty: _selectedDifficulty,
        );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedDifficulty = null;
    });
    context.read<MeditationProvider>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              controller: _searchController,
              hint: 'Buscar meditaciones...',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) => _applyFilters(),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
            ),
          ),

          // Filter chips
          if (_selectedCategory != null || _selectedDifficulty != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_selectedCategory != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_selectedCategory!),
                        onDeleted: () {
                          setState(() => _selectedCategory = null);
                          _applyFilters();
                        },
                      ),
                    ),
                  if (_selectedDifficulty != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_selectedDifficulty!),
                        onDeleted: () {
                          setState(() => _selectedDifficulty = null);
                          _applyFilters();
                        },
                      ),
                    ),
                  TextButton.icon(
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Limpiar filtros'),
                    onPressed: _clearFilters,
                  ),
                ],
              ),
            ),

          // Meditation list
          Expanded(
            child: Consumer<MeditationProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const ListShimmer();
                }

                if (provider.error != null) {
                  return CustomErrorWidget(
                    message: provider.error!,
                    onRetry: () => provider.loadMeditations(),
                  );
                }

                if (provider.filteredMeditations.isEmpty) {
                  return EmptyState(
                    icon: Icons.self_improvement,
                    title: 'No hay meditaciones',
                    message: _searchController.text.isNotEmpty ||
                            _selectedCategory != null ||
                            _selectedDifficulty != null
                        ? 'No se encontraron meditaciones con los filtros aplicados'
                        : 'Aún no hay meditaciones disponibles',
                    actionLabel: _searchController.text.isNotEmpty ||
                            _selectedCategory != null ||
                            _selectedDifficulty != null
                        ? 'Limpiar filtros'
                        : null,
                    onActionPressed: _searchController.text.isNotEmpty ||
                            _selectedCategory != null ||
                            _selectedDifficulty != null
                        ? _clearFilters
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadMeditations(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.filteredMeditations.length,
                    itemBuilder: (context, index) {
                      final meditation = provider.filteredMeditations[index];
                      return _MeditationCard(meditation: meditation);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Categoría',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Consumer<MeditationProvider>(
                builder: (context, provider, _) {
                  return Wrap(
                    spacing: 8,
                    children: provider.categories.map((category) {
                      return ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : null;
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('Dificultad',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Principiante', 'Intermedio', 'Avanzado']
                    .map((difficulty) {
                  return ChoiceChip(
                    label: Text(difficulty),
                    selected: _selectedDifficulty == difficulty,
                    onSelected: (selected) {
                      setState(() {
                        _selectedDifficulty = selected ? difficulty : null;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Limpiar'),
          ),
          ElevatedButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}

class _MeditationCard extends StatelessWidget {
  final MeditationModel meditation;

  const _MeditationCard({required this.meditation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/meditation-detail',
            arguments: meditation.id,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: meditation.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: meditation.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Icon(Icons.self_improvement, size: 48),
                      ),
                    )
                  : Container(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.self_improvement, size: 48),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    meditation.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    meditation.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Tags and info
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Duration
                      _InfoChip(
                        icon: Icons.access_time,
                        label: '${meditation.duration} min',
                      ),

                      // Category
                      _InfoChip(
                        icon: Icons.category,
                        label: meditation.category,
                      ),

                      // Difficulty
                      if (meditation.difficulty != null)
                        _InfoChip(
                          icon: Icons.signal_cellular_alt,
                          label: meditation.difficulty!,
                        ),

                      // Rating
                      if (meditation.averageRating != null &&
                          meditation.averageRating! > 0)
                        _InfoChip(
                          icon: Icons.star,
                          label: meditation.averageRating!.toStringAsFixed(1),
                          color: Colors.amber,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).colorScheme.primary)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color ?? Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
