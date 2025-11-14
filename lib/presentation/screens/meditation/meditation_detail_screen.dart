import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/meditation_provider.dart';
import '../../widgets/audio_player_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_button.dart';
import '../../../data/models/meditation_model.dart';

class MeditationDetailScreen extends StatefulWidget {
  final String meditationId;

  const MeditationDetailScreen({
    super.key,
    required this.meditationId,
  });

  @override
  State<MeditationDetailScreen> createState() => _MeditationDetailScreenState();
}

class _MeditationDetailScreenState extends State<MeditationDetailScreen> {
  int _selectedRating = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<MeditationProvider>()
          .loadMeditationById(widget.meditationId);
    });
  }

  Future<void> _submitRating() async {
    if (_selectedRating > 0) {
      try {
        await context
            .read<MeditationProvider>()
            .rateMeditation(widget.meditationId, _selectedRating);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gracias por tu valoración'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al enviar valoración: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MeditationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Cargando meditación...');
          }

          if (provider.error != null) {
            return CustomErrorWidget(
              message: provider.error!,
              onRetry: () =>
                  provider.loadMeditationById(widget.meditationId),
            );
          }

          final meditation = provider.currentMeditation;

          if (meditation == null) {
            return const CustomErrorWidget(
              message: 'Meditación no encontrada',
            );
          }

          return CustomScrollView(
            slivers: [
              // App bar with image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: meditation.imageUrl != null
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
                            child: const Icon(
                              Icons.self_improvement,
                              size: 64,
                            ),
                          ),
                        )
                      : Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Icon(
                            Icons.self_improvement,
                            size: 64,
                          ),
                        ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      setState(() => _isFavorite = !_isFavorite);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isFavorite
                                ? 'Agregado a favoritos'
                                : 'Eliminado de favoritos',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        meditation.title,
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),

                      // Info chips
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.access_time,
                            label: '${meditation.duration} min',
                          ),
                          _InfoChip(
                            icon: Icons.category,
                            label: meditation.category,
                          ),
                          if (meditation.difficulty != null)
                            _InfoChip(
                              icon: Icons.signal_cellular_alt,
                              label: meditation.difficulty!,
                            ),
                          if (meditation.averageRating != null &&
                              meditation.averageRating! > 0)
                            _InfoChip(
                              icon: Icons.star,
                              label:
                                  '${meditation.averageRating!.toStringAsFixed(1)} (${meditation.ratingsCount ?? 0})',
                              color: Colors.amber,
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Descripción',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        meditation.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.8),
                              height: 1.5,
                            ),
                      ),

                      const SizedBox(height: 32),

                      // Audio player
                      if (meditation.audioUrl != null) ...[
                        Text(
                          'Reproducir meditación',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        AudioPlayerWidget(
                          audioUrl: meditation.audioUrl!,
                          onComplete: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    '¡Felicidades por completar la meditación!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Audio no disponible para esta meditación',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Rating section
                      Text(
                        'Valora esta meditación',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return IconButton(
                                  icon: Icon(
                                    index < _selectedRating
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 36,
                                  ),
                                  color: Colors.amber,
                                  onPressed: () {
                                    setState(() => _selectedRating = index + 1);
                                  },
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Enviar valoración',
                        onPressed: _selectedRating > 0 ? _submitRating : null,
                        width: double.infinity,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).colorScheme.primary)
            .withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color ?? Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
