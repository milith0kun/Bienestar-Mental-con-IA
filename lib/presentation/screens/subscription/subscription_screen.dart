import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selectedPlan = 'monthly';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().loadSubscriptionStatus();
      context.read<SubscriptionProvider>().loadPlans();
    });
  }

  Future<void> _subscribe(String planId) async {
    try {
      await context.read<SubscriptionProvider>().upgradeToPremium(planId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Bienvenido a Premium!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al suscribirse: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suscripción Premium'),
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Cargando planes...');
          }

          final subscription = provider.subscription;
          final isPremium = subscription?.status == 'active';

          if (isPremium) {
            return _buildCurrentSubscriptionView(subscription!);
          }

          return _buildUpgradeView();
        },
      ),
    );
  }

  Widget _buildCurrentSubscriptionView(subscription) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Premium badge
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.workspace_premium,
                size: 64,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(height: 16),
              Text(
                'Eres Premium',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Disfruta de todas las funciones premium',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Subscription details
        _DetailCard(
          icon: Icons.card_membership,
          title: 'Plan',
          value: subscription.planType?.toUpperCase() ?? 'Premium',
        ),
        const SizedBox(height: 12),
        _DetailCard(
          icon: Icons.check_circle,
          title: 'Estado',
          value: 'Activo',
          valueColor: Colors.green,
        ),
        if (subscription.endDate != null) ...[
          const SizedBox(height: 12),
          _DetailCard(
            icon: Icons.calendar_today,
            title: 'Próxima renovación',
            value: subscription.endDate.toString().split(' ')[0],
          ),
        ],

        const SizedBox(height: 32),

        // Benefits
        Text(
          'Tus beneficios Premium',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ..._premiumFeatures.map((feature) => _FeatureTile(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              enabled: true,
            )),

        const SizedBox(height: 32),

        // Cancel button
        OutlinedButton(
          onPressed: () => _showCancelDialog(),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            side: BorderSide(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          child: const Text('Cancelar suscripción'),
        ),
      ],
    );
  }

  Widget _buildUpgradeView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Desbloquea Premium',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Accede a todas las funciones premium',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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

        const SizedBox(height: 32),

        // Plan selector
        Text(
          'Elige tu plan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        _PlanCard(
          planId: 'monthly',
          title: 'Mensual',
          price: '\$9.99',
          period: 'mes',
          isSelected: _selectedPlan == 'monthly',
          onTap: () => setState(() => _selectedPlan = 'monthly'),
        ),
        const SizedBox(height: 12),
        _PlanCard(
          planId: 'yearly',
          title: 'Anual',
          price: '\$99.99',
          period: 'año',
          savings: 'Ahorra 17%',
          isSelected: _selectedPlan == 'yearly',
          onTap: () => setState(() => _selectedPlan = 'yearly'),
          recommended: true,
        ),

        const SizedBox(height: 32),

        // Features
        Text(
          'Incluye',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ..._premiumFeatures.map((feature) => _FeatureTile(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              enabled: true,
            )),

        const SizedBox(height: 32),

        // Subscribe button
        CustomButton(
          text: 'Suscribirse ahora',
          onPressed: () => _subscribe(_selectedPlan),
          width: double.infinity,
          icon: Icons.check_circle,
        ),

        const SizedBox(height: 16),

        Text(
          'Cancela cuando quieras. Sin compromisos.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _showCancelDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar suscripción'),
        content: const Text(
          '¿Estás seguro de que quieres cancelar tu suscripción premium? '
          'Perderás acceso a todas las funciones premium al final de tu período actual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, mantener'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<SubscriptionProvider>().cancelSubscription();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Suscripción cancelada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cancelar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  static final List<Map<String, dynamic>> _premiumFeatures = [
    {
      'icon': Icons.self_improvement,
      'title': 'Meditaciones ilimitadas y exclusivas',
    },
    {
      'icon': Icons.psychology,
      'title': 'Análisis AI avanzado de tu diario',
    },
    {
      'icon': Icons.trending_up,
      'title': 'Estadísticas detalladas y personalizadas',
    },
    {
      'icon': Icons.notifications_active,
      'title': 'Recordatorios personalizados',
    },
    {
      'icon': Icons.download,
      'title': 'Descarga meditaciones offline',
    },
    {
      'icon': Icons.support_agent,
      'title': 'Soporte prioritario',
    },
  ];
}

class _PlanCard extends StatelessWidget {
  final String planId;
  final String title;
  final String price;
  final String period;
  final String? savings;
  final bool isSelected;
  final VoidCallback onTap;
  final bool recommended;

  const _PlanCard({
    required this.planId,
    required this.title,
    required this.price,
    required this.period,
    this.savings,
    required this.isSelected,
    required this.onTap,
    this.recommended = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (savings != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          savings!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Text(
                      '/$period',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (recommended)
          Positioned(
            top: -8,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Recomendado',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool enabled;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: enabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: enabled
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
            ),
          ),
          if (enabled)
            Icon(
              Icons.check,
              color: Colors.green,
            ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: valueColor,
                        ),
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
