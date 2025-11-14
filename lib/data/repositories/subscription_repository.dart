import '../../core/config/api_config.dart';
import '../datasources/api_client.dart';
import '../models/subscription_model.dart';

class SubscriptionRepository {
  final ApiClient _apiClient;

  SubscriptionRepository(this._apiClient);

  /// Obtener estado de suscripción
  Future<SubscriptionModel> getSubscriptionStatus() async {
    try {
      final response = await _apiClient.get('${ApiConfig.subscriptions}/status');

      if (response.data['success'] == true) {
        return SubscriptionModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Error al obtener estado');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener características de planes
  Future<PlanFeaturesModel> getPlanFeatures() async {
    try {
      final response = await _apiClient.get('${ApiConfig.subscriptions}/features');

      if (response.data['success'] == true) {
        return PlanFeaturesModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Error al obtener planes');
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar a premium (modo demo)
  Future<SubscriptionModel> upgradeToPremiumDemo() async {
    try {
      final response = await _apiClient.post('${ApiConfig.subscriptions}/upgrade-demo');

      if (response.data['success'] == true) {
        return SubscriptionModel.fromJson({
          'subscription': response.data['data']['subscription'],
        });
      }

      throw Exception(response.data['message'] ?? 'Error al actualizar');
    } catch (e) {
      rethrow;
    }
  }

  /// Cancelar suscripción
  Future<bool> cancelSubscription() async {
    try {
      final response = await _apiClient.post('${ApiConfig.subscriptions}/cancel');

      return response.data['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  /// Crear sesión de checkout (placeholder para Stripe)
  Future<Map<String, dynamic>> createCheckoutSession() async {
    try {
      final response = await _apiClient.post('${ApiConfig.subscriptions}/create-checkout');

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception(response.data['message'] ?? 'Error al crear checkout');
    } catch (e) {
      rethrow;
    }
  }
}
