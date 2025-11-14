import 'package:flutter_test/flutter_test.dart';
import 'package:mindflow/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson creates valid UserModel', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'name': 'Test User',
        'profilePicture': 'https://example.com/photo.jpg',
        'authProvider': 'email',
        'subscription': {
          'plan': 'premium',
          'status': 'active',
          'startDate': '2024-01-01T00:00:00.000Z',
        },
        'preferences': {
          'notificationsEnabled': true,
          'meditationReminder': {
            'enabled': true,
            'time': '09:00',
          },
          'moodReminder': {
            'enabled': false,
            'time': '20:00',
          },
        },
        'stats': {
          'totalMeditations': 10,
          'totalMeditationTime': 3600,
          'totalMeditationTimeFormatted': '1h 0m',
          'consecutiveDays': 5,
          'journalEntries': 8,
          'journalEntriesThisMonth': 3,
          'journalEntriesRemaining': 7,
        },
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.profilePicture, 'https://example.com/photo.jpg');
      expect(user.authProvider, 'email');
      expect(user.subscription.plan, 'premium');
      expect(user.subscription.status, 'active');
      expect(user.preferences?.notificationsEnabled, true);
      expect(user.stats?.totalMeditations, 10);
    });

    test('toJson creates valid JSON', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        authProvider: 'email',
        subscription: SubscriptionModel(
          plan: 'free',
          status: 'active',
        ),
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test User');
      expect(json['authProvider'], 'email');
      expect(json['subscription']['plan'], 'free');
    });

    test('isPremium returns true for premium users', () {
      final premiumUser = UserModel(
        id: '123',
        email: 'premium@example.com',
        name: 'Premium User',
        authProvider: 'email',
        subscription: SubscriptionModel(
          plan: 'premium',
          status: 'active',
        ),
      );

      expect(premiumUser.isPremium, true);
    });

    test('isPremium returns false for free users', () {
      final freeUser = UserModel(
        id: '123',
        email: 'free@example.com',
        name: 'Free User',
        authProvider: 'email',
        subscription: SubscriptionModel(
          plan: 'free',
          status: 'active',
        ),
      );

      expect(freeUser.isPremium, false);
    });

    test('copyWith creates new instance with updated values', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        authProvider: 'email',
        subscription: SubscriptionModel(
          plan: 'free',
          status: 'active',
        ),
      );

      final updatedUser = user.copyWith(name: 'Updated Name');

      expect(updatedUser.id, user.id);
      expect(updatedUser.email, user.email);
      expect(updatedUser.name, 'Updated Name');
      expect(updatedUser.authProvider, user.authProvider);
    });
  });

  group('SubscriptionModel', () {
    test('fromJson creates valid SubscriptionModel', () {
      final json = {
        'plan': 'premium',
        'status': 'active',
        'startDate': '2024-01-01T00:00:00.000Z',
        'endDate': '2024-12-31T23:59:59.999Z',
      };

      final subscription = SubscriptionModel.fromJson(json);

      expect(subscription.plan, 'premium');
      expect(subscription.status, 'active');
      expect(subscription.startDate, isNotNull);
      expect(subscription.endDate, isNotNull);
    });

    test('handles missing dates gracefully', () {
      final json = {
        'plan': 'free',
        'status': 'active',
      };

      final subscription = SubscriptionModel.fromJson(json);

      expect(subscription.plan, 'free');
      expect(subscription.status, 'active');
      expect(subscription.startDate, isNull);
      expect(subscription.endDate, isNull);
    });
  });

  group('StatsModel', () {
    test('fromJson creates valid StatsModel', () {
      final json = {
        'totalMeditations': 15,
        'totalMeditationTime': 7200,
        'totalMeditationTimeFormatted': '2h 0m',
        'consecutiveDays': 7,
        'journalEntries': 10,
        'journalEntriesThisMonth': 5,
        'journalEntriesRemaining': 5,
      };

      final stats = StatsModel.fromJson(json);

      expect(stats.totalMeditations, 15);
      expect(stats.totalMeditationTime, 7200);
      expect(stats.totalMeditationTimeFormatted, '2h 0m');
      expect(stats.consecutiveDays, 7);
      expect(stats.journalEntries, 10);
      expect(stats.journalEntriesThisMonth, 5);
      expect(stats.journalEntriesRemaining, 5);
    });

    test('handles unlimited journal entries', () {
      final json = {
        'totalMeditations': 0,
        'totalMeditationTime': 0,
        'totalMeditationTimeFormatted': '0m',
        'consecutiveDays': 0,
        'journalEntries': 0,
        'journalEntriesThisMonth': 0,
        'journalEntriesRemaining': 'unlimited',
      };

      final stats = StatsModel.fromJson(json);

      expect(stats.journalEntriesRemaining, 'unlimited');
    });
  });
}
