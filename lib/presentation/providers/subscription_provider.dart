import 'package:flutter/foundation.dart';
import '../../data/models/subscription_model.dart';
import '../../data/repositories/subscription_repository.dart';

class SubscriptionProvider with ChangeNotifier {
  final SubscriptionRepository _subscriptionRepository;

  SubscriptionProvider(this._subscriptionRepository);

  // State
  SubscriptionModel? _subscription;
  PlanFeaturesModel? _planFeatures;
  bool _isLoading = false;
  String? _error;

  // Getters
  SubscriptionModel? get subscription => _subscription;
  PlanFeaturesModel? get planFeatures => _planFeatures;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPremium => _subscription?.isPremium ?? false;
  String get currentPlan => _subscription?.plan ?? 'free';

  /// Cargar estado de suscripción
  Future<void> loadSubscriptionStatus() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _subscription = await _subscriptionRepository.getSubscriptionStatus();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar características de planes
  Future<void> loadPlanFeatures() async {
    try {
      _planFeatures = await _subscriptionRepository.getPlanFeatures();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Actualizar a premium (modo demo)
  Future<bool> upgradeToPremiumDemo() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _subscription = await _subscriptionRepository.upgradeToPremiumDemo();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cancelar suscripción
  Future<bool> cancelSubscription() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _subscriptionRepository.cancelSubscription();

      if (success) {
        await loadSubscriptionStatus();
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Crear sesión de checkout
  Future<Map<String, dynamic>?> createCheckoutSession() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _subscriptionRepository.createCheckoutSession();

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Verificar si tiene una característica
  bool hasFeature(String featureName) {
    return _subscription?.hasFeature(featureName) ?? false;
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
