import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dishaajyoti/services/firebase/firestore_service.dart';
import 'package:dishaajyoti/models/firebase/user_profile_model.dart';
import 'package:dishaajyoti/models/firebase/service_report_model.dart';
import 'package:dishaajyoti/models/firebase/order_model.dart';

/// Tests for FirestoreService
///
/// Note: These tests focus on service structure and basic functionality.
/// Full integration tests with Firestore require Firebase Test Lab or emulators.
///
/// To run with Firebase emulator:
/// 1. Install Firebase CLI: npm install -g firebase-tools
/// 2. Start emulator: firebase emulators:start --only firestore
/// 3. Run tests: flutter test test/services/firebase/firestore_service_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirestoreService - Singleton Pattern', () {
    test('should return singleton instance', () {
      final instance1 = FirestoreService.instance;
      final instance2 = FirestoreService.instance;
      final instance3 = FirestoreService();

      expect(instance1, equals(instance2));
      expect(instance1, equals(instance3));
      expect(instance2, equals(instance3));
    });

    test('should maintain same instance across multiple calls', () {
      final instances = List.generate(5, (_) => FirestoreService.instance);

      for (var i = 0; i < instances.length - 1; i++) {
        expect(instances[i], equals(instances[i + 1]));
      }
    });
  });

  group('FirestoreService - Method Availability', () {
    test('should have user profile CRUD methods', () {
      final service = FirestoreService.instance;

      expect(service.createUserProfile, isA<Function>());
      expect(service.getUserProfile, isA<Function>());
      expect(service.updateUserProfile, isA<Function>());
    });

    test('should have service report CRUD methods', () {
      final service = FirestoreService.instance;

      expect(service.createServiceReport, isA<Function>());
      expect(service.getServiceReport, isA<Function>());
      expect(service.getUserReports, isA<Function>());
      expect(service.updateReportStatus, isA<Function>());
      expect(service.deleteReport, isA<Function>());
    });

    test('should have order CRUD methods', () {
      final service = FirestoreService.instance;

      expect(service.createOrder, isA<Function>());
      expect(service.getOrder, isA<Function>());
      expect(service.getUserOrders, isA<Function>());
      expect(service.updateOrderStatus, isA<Function>());
    });

    test('should have real-time listener methods', () {
      final service = FirestoreService.instance;

      expect(service.watchReport, isA<Function>());
      expect(service.watchUserReports, isA<Function>());
      expect(service.watchUserProfile, isA<Function>());
      expect(service.watchUserOrders, isA<Function>());
      expect(service.watchOrder, isA<Function>());
    });

    test('should have pagination helper methods', () {
      final service = FirestoreService.instance;

      expect(service.getLastDocument, isA<Function>());
      expect(service.countUserReports, isA<Function>());
    });

    test('should have batch operation methods', () {
      final service = FirestoreService.instance;

      expect(service.batchWrite, isA<Function>());
    });
  });

  group('FirestoreService - User Profile Operations', () {
    test('should have updateFCMToken method', () {
      final service = FirestoreService.instance;

      expect(service.updateFCMToken, isA<Function>());
    });

    test('should have updateUserPreferences method', () {
      final service = FirestoreService.instance;

      expect(service.updateUserPreferences, isA<Function>());
    });
  });

  group('FirestoreService - Service Report Operations', () {
    test('should have getUserReportsByStatus method', () {
      final service = FirestoreService.instance;

      expect(service.getUserReportsByStatus, isA<Function>());
    });

    test('should have updateReportFiles method', () {
      final service = FirestoreService.instance;

      expect(service.updateReportFiles, isA<Function>());
    });

    test('should have updateReportData method', () {
      final service = FirestoreService.instance;

      expect(service.updateReportData, isA<Function>());
    });

    test('should have watchUserReportsByStatus method', () {
      final service = FirestoreService.instance;

      expect(service.watchUserReportsByStatus, isA<Function>());
    });
  });

  group('FirestoreService - Order Operations', () {
    test('should have updateOrderPayment method', () {
      final service = FirestoreService.instance;

      expect(service.updateOrderPayment, isA<Function>());
    });

    test('should have linkOrderToReport method', () {
      final service = FirestoreService.instance;

      expect(service.linkOrderToReport, isA<Function>());
    });
  });

  group('FirestoreService - Data Model Creation', () {
    test('should create valid UserProfile model', () {
      final now = DateTime.now();
      final profile = UserProfile(
        id: 'test-user-id',
        email: 'test@example.com',
        name: 'Test User',
        phone: '+1234567890',
        dateOfBirth: DateTime(1990, 1, 1),
        createdAt: now,
        updatedAt: now,
      );

      expect(profile.id, equals('test-user-id'));
      expect(profile.email, equals('test@example.com'));
      expect(profile.name, equals('Test User'));
      expect(profile.phone, equals('+1234567890'));
      expect(profile.subscription.type, equals('free'));
      expect(profile.preferences.language, equals('en'));
    });

    test('should create valid ServiceReport model', () {
      final now = DateTime.now();
      final report = ServiceReport(
        id: 'test-report-id',
        userId: 'test-user-id',
        serviceType: ServiceType.kundali,
        status: ServiceReportStatus.pending,
        createdAt: now,
        data: {'name': 'Test', 'birthDate': '1990-01-01'},
      );

      expect(report.id, equals('test-report-id'));
      expect(report.userId, equals('test-user-id'));
      expect(report.serviceType, equals(ServiceType.kundali));
      expect(report.status, equals(ServiceReportStatus.pending));
      expect(report.data['name'], equals('Test'));
    });

    test('should create valid FirebaseOrder model', () {
      final now = DateTime.now();
      final order = FirebaseOrder(
        id: 'test-order-id',
        userId: 'test-user-id',
        serviceType: 'kundali',
        amount: 299.0,
        currency: 'INR',
        status: FirebaseOrderStatus.pending,
        createdAt: now,
        testMode: true,
      );

      expect(order.id, equals('test-order-id'));
      expect(order.userId, equals('test-user-id'));
      expect(order.serviceType, equals('kundali'));
      expect(order.amount, equals(299.0));
      expect(order.currency, equals('INR'));
      expect(order.status, equals(FirebaseOrderStatus.pending));
      expect(order.testMode, isTrue);
    });
  });

  group('FirestoreService - Model Serialization', () {
    test('UserProfile should serialize to Firestore format', () {
      final now = DateTime.now();
      final profile = UserProfile(
        id: 'test-user-id',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: now,
        updatedAt: now,
      );

      final firestoreData = profile.toFirestore();

      expect(firestoreData['email'], equals('test@example.com'));
      expect(firestoreData['name'], equals('Test User'));
      expect(firestoreData['createdAt'], isA<Timestamp>());
      expect(firestoreData['updatedAt'], isA<Timestamp>());
      expect(firestoreData['subscription'], isA<Map>());
      expect(firestoreData['preferences'], isA<Map>());
    });

    test('ServiceReport should serialize to Firestore format', () {
      final now = DateTime.now();
      final report = ServiceReport(
        id: 'test-report-id',
        userId: 'test-user-id',
        serviceType: ServiceType.kundali,
        status: ServiceReportStatus.pending,
        createdAt: now,
        data: {'test': 'data'},
      );

      final firestoreData = report.toFirestore();

      expect(firestoreData['userId'], equals('test-user-id'));
      expect(firestoreData['serviceType'], equals('kundali'));
      expect(firestoreData['status'], equals('pending'));
      expect(firestoreData['createdAt'], isA<Timestamp>());
      expect(firestoreData['data'], isA<Map>());
    });

    test('FirebaseOrder should serialize to Firestore format', () {
      final now = DateTime.now();
      final order = FirebaseOrder(
        id: 'test-order-id',
        userId: 'test-user-id',
        serviceType: 'kundali',
        amount: 299.0,
        status: FirebaseOrderStatus.pending,
        createdAt: now,
      );

      final firestoreData = order.toFirestore();

      expect(firestoreData['userId'], equals('test-user-id'));
      expect(firestoreData['serviceType'], equals('kundali'));
      expect(firestoreData['amount'], equals(299.0));
      expect(firestoreData['status'], equals('pending'));
      expect(firestoreData['createdAt'], isA<Timestamp>());
    });
  });

  group('FirestoreService - Enum Conversions', () {
    test('ServiceReportStatus should convert from string', () {
      expect(
        ServiceReportStatus.fromString('pending'),
        equals(ServiceReportStatus.pending),
      );
      expect(
        ServiceReportStatus.fromString('scheduled'),
        equals(ServiceReportStatus.scheduled),
      );
      expect(
        ServiceReportStatus.fromString('processing'),
        equals(ServiceReportStatus.processing),
      );
      expect(
        ServiceReportStatus.fromString('completed'),
        equals(ServiceReportStatus.completed),
      );
      expect(
        ServiceReportStatus.fromString('failed'),
        equals(ServiceReportStatus.failed),
      );
    });

    test('ServiceReportStatus should convert to string', () {
      expect(ServiceReportStatus.pending.toString(), equals('pending'));
      expect(ServiceReportStatus.scheduled.toString(), equals('scheduled'));
      expect(ServiceReportStatus.processing.toString(), equals('processing'));
      expect(ServiceReportStatus.completed.toString(), equals('completed'));
      expect(ServiceReportStatus.failed.toString(), equals('failed'));
    });

    test('ServiceType should convert from string', () {
      expect(ServiceType.fromString('kundali'), equals(ServiceType.kundali));
      expect(
        ServiceType.fromString('palmistry'),
        equals(ServiceType.palmistry),
      );
      expect(
        ServiceType.fromString('numerology'),
        equals(ServiceType.numerology),
      );
      expect(
        ServiceType.fromString('matchmaking'),
        equals(ServiceType.matchmaking),
      );
      expect(ServiceType.fromString('panchang'), equals(ServiceType.panchang));
    });

    test('ServiceType should convert to string', () {
      expect(ServiceType.kundali.toString(), equals('kundali'));
      expect(ServiceType.palmistry.toString(), equals('palmistry'));
      expect(ServiceType.numerology.toString(), equals('numerology'));
      expect(ServiceType.matchmaking.toString(), equals('matchmaking'));
      expect(ServiceType.panchang.toString(), equals('panchang'));
    });

    test('FirebaseOrderStatus should convert from string', () {
      expect(
        FirebaseOrderStatus.fromString('pending'),
        equals(FirebaseOrderStatus.pending),
      );
      expect(
        FirebaseOrderStatus.fromString('paid'),
        equals(FirebaseOrderStatus.paid),
      );
      expect(
        FirebaseOrderStatus.fromString('failed'),
        equals(FirebaseOrderStatus.failed),
      );
      expect(
        FirebaseOrderStatus.fromString('refunded'),
        equals(FirebaseOrderStatus.refunded),
      );
      expect(
        FirebaseOrderStatus.fromString('cancelled'),
        equals(FirebaseOrderStatus.cancelled),
      );
    });

    test('FirebaseOrderStatus should convert to string', () {
      expect(FirebaseOrderStatus.pending.toString(), equals('pending'));
      expect(FirebaseOrderStatus.paid.toString(), equals('paid'));
      expect(FirebaseOrderStatus.failed.toString(), equals('failed'));
      expect(FirebaseOrderStatus.refunded.toString(), equals('refunded'));
      expect(FirebaseOrderStatus.cancelled.toString(), equals('cancelled'));
    });
  });

  group('FirestoreService - Model Properties', () {
    test('ServiceReport should calculate isExpired correctly', () {
      final now = DateTime.now();

      // Not expired
      final futureReport = ServiceReport(
        id: 'test-id',
        userId: 'user-id',
        serviceType: ServiceType.kundali,
        status: ServiceReportStatus.completed,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 30)),
      );
      expect(futureReport.isExpired, isFalse);

      // Expired
      final expiredReport = ServiceReport(
        id: 'test-id',
        userId: 'user-id',
        serviceType: ServiceType.kundali,
        status: ServiceReportStatus.completed,
        createdAt: now,
        expiresAt: now.subtract(const Duration(days: 1)),
      );
      expect(expiredReport.isExpired, isTrue);

      // No expiry date
      final noExpiryReport = ServiceReport(
        id: 'test-id',
        userId: 'user-id',
        serviceType: ServiceType.kundali,
        status: ServiceReportStatus.completed,
        createdAt: now,
      );
      expect(noExpiryReport.isExpired, isFalse);
    });

    test('ServiceReport should calculate isReady correctly', () {
      final now = DateTime.now();

      // Ready report
      final readyReport = ServiceReport(
        id: 'test-id',
        userId: 'user-id',
        serviceType: ServiceType.kundali,
        status: ServiceReportStatus.completed,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 30)),
      );
      expect(readyReport.isReady, isTrue);

      // Not completed
      final pendingReport = ServiceReport(
        id: 'test-id',
        userId: 'user-id',
        serviceType: ServiceType.kundali,
        status: ServiceReportStatus.pending,
        createdAt: now,
      );
      expect(pendingReport.isReady, isFalse);

      // Expired
      final expiredReport = ServiceReport(
        id: 'test-id',
        userId: 'user-id',
        serviceType: ServiceType.kundali,
        status: ServiceReportStatus.completed,
        createdAt: now,
        expiresAt: now.subtract(const Duration(days: 1)),
      );
      expect(expiredReport.isReady, isFalse);
    });

    test('FirebaseOrder should have correct status properties', () {
      final now = DateTime.now();

      final paidOrder = FirebaseOrder(
        id: 'test-id',
        userId: 'user-id',
        serviceType: 'kundali',
        amount: 299.0,
        status: FirebaseOrderStatus.paid,
        createdAt: now,
      );
      expect(paidOrder.isPaid, isTrue);
      expect(paidOrder.isPending, isFalse);
      expect(paidOrder.hasFailed, isFalse);

      final pendingOrder = FirebaseOrder(
        id: 'test-id',
        userId: 'user-id',
        serviceType: 'kundali',
        amount: 299.0,
        status: FirebaseOrderStatus.pending,
        createdAt: now,
      );
      expect(pendingOrder.isPaid, isFalse);
      expect(pendingOrder.isPending, isTrue);
      expect(pendingOrder.hasFailed, isFalse);

      final failedOrder = FirebaseOrder(
        id: 'test-id',
        userId: 'user-id',
        serviceType: 'kundali',
        amount: 299.0,
        status: FirebaseOrderStatus.failed,
        createdAt: now,
      );
      expect(failedOrder.isPaid, isFalse);
      expect(failedOrder.isPending, isFalse);
      expect(failedOrder.hasFailed, isTrue);
    });

    test('SubscriptionInfo should calculate isActive correctly', () {
      // Free subscription
      final freeSubscription = SubscriptionInfo(type: 'free');
      expect(freeSubscription.isActive, isTrue);

      // Active premium subscription
      final activeSubscription = SubscriptionInfo(
        type: 'premium',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      expect(activeSubscription.isActive, isTrue);

      // Expired premium subscription
      final expiredSubscription = SubscriptionInfo(
        type: 'premium',
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(expiredSubscription.isActive, isFalse);

      // Premium without expiry date
      final noExpirySubscription = SubscriptionInfo(type: 'premium');
      expect(noExpirySubscription.isActive, isFalse);
    });
  });

  group('FirestoreService - Model CopyWith', () {
    test('UserProfile copyWith should create modified copy', () {
      final now = DateTime.now();
      final original = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: now,
        updatedAt: now,
      );

      final modified = original.copyWith(
        name: 'Modified User',
        phone: '+1234567890',
      );

      expect(modified.id, equals(original.id));
      expect(modified.email, equals(original.email));
      expect(modified.name, equals('Modified User'));
      expect(modified.phone, equals('+1234567890'));
      expect(modified.createdAt, equals(original.createdAt));
    });

    test('ServiceReport copyWith should create modified copy', () {
      final now = DateTime.now();
      final original = ServiceReport(
        id: 'test-id',
        userId: 'user-id',
        serviceType: ServiceType.kundali,
        status: ServiceReportStatus.pending,
        createdAt: now,
      );

      final modified = original.copyWith(
        status: ServiceReportStatus.completed,
        completedAt: now,
      );

      expect(modified.id, equals(original.id));
      expect(modified.userId, equals(original.userId));
      expect(modified.serviceType, equals(original.serviceType));
      expect(modified.status, equals(ServiceReportStatus.completed));
      expect(modified.completedAt, equals(now));
    });

    test('FirebaseOrder copyWith should create modified copy', () {
      final now = DateTime.now();
      final original = FirebaseOrder(
        id: 'test-id',
        userId: 'user-id',
        serviceType: 'kundali',
        amount: 299.0,
        status: FirebaseOrderStatus.pending,
        createdAt: now,
      );

      final modified = original.copyWith(
        status: FirebaseOrderStatus.paid,
        paymentId: 'payment-123',
        paidAt: now,
      );

      expect(modified.id, equals(original.id));
      expect(modified.userId, equals(original.userId));
      expect(modified.status, equals(FirebaseOrderStatus.paid));
      expect(modified.paymentId, equals('payment-123'));
      expect(modified.paidAt, equals(now));
    });
  });

  group('FirestoreService - ReportFiles Model', () {
    test('should create ReportFiles with default values', () {
      final files = ReportFiles();

      expect(files.pdfUrl, isNull);
      expect(files.imageUrls, isEmpty);
    });

    test('should create ReportFiles with values', () {
      final files = ReportFiles(
        pdfUrl: 'https://example.com/report.pdf',
        imageUrls: [
          'https://example.com/chart1.png',
          'https://example.com/chart2.png'
        ],
      );

      expect(files.pdfUrl, equals('https://example.com/report.pdf'));
      expect(files.imageUrls.length, equals(2));
      expect(files.imageUrls[0], equals('https://example.com/chart1.png'));
    });

    test('ReportFiles should serialize to map', () {
      final files = ReportFiles(
        pdfUrl: 'https://example.com/report.pdf',
        imageUrls: ['https://example.com/chart.png'],
      );

      final map = files.toMap();

      expect(map['pdfUrl'], equals('https://example.com/report.pdf'));
      expect(map['imageUrls'], isA<List>());
      expect((map['imageUrls'] as List).length, equals(1));
    });

    test('ReportFiles should deserialize from map', () {
      final map = {
        'pdfUrl': 'https://example.com/report.pdf',
        'imageUrls': ['https://example.com/chart.png'],
      };

      final files = ReportFiles.fromMap(map);

      expect(files.pdfUrl, equals('https://example.com/report.pdf'));
      expect(files.imageUrls.length, equals(1));
    });

    test('ReportFiles copyWith should create modified copy', () {
      final original = ReportFiles(
        pdfUrl: 'https://example.com/report.pdf',
        imageUrls: ['https://example.com/chart1.png'],
      );

      final modified = original.copyWith(
        imageUrls: [
          'https://example.com/chart1.png',
          'https://example.com/chart2.png'
        ],
      );

      expect(modified.pdfUrl, equals(original.pdfUrl));
      expect(modified.imageUrls.length, equals(2));
    });
  });

  group('FirestoreService - UserPreferences Model', () {
    test('should create UserPreferences with default values', () {
      final preferences = UserPreferences();

      expect(preferences.language, equals('en'));
      expect(preferences.chartStyle, equals('northIndian'));
      expect(preferences.notifications, isTrue);
    });

    test('should create UserPreferences with custom values', () {
      final preferences = UserPreferences(
        language: 'hi',
        chartStyle: 'southIndian',
        notifications: false,
      );

      expect(preferences.language, equals('hi'));
      expect(preferences.chartStyle, equals('southIndian'));
      expect(preferences.notifications, isFalse);
    });

    test('UserPreferences should serialize to map', () {
      final preferences = UserPreferences(
        language: 'hi',
        chartStyle: 'southIndian',
        notifications: false,
      );

      final map = preferences.toMap();

      expect(map['language'], equals('hi'));
      expect(map['chartStyle'], equals('southIndian'));
      expect(map['notifications'], isFalse);
    });

    test('UserPreferences should deserialize from map', () {
      final map = {
        'language': 'hi',
        'chartStyle': 'southIndian',
        'notifications': false,
      };

      final preferences = UserPreferences.fromMap(map);

      expect(preferences.language, equals('hi'));
      expect(preferences.chartStyle, equals('southIndian'));
      expect(preferences.notifications, isFalse);
    });

    test('UserPreferences copyWith should create modified copy', () {
      final original = UserPreferences(
        language: 'en',
        chartStyle: 'northIndian',
        notifications: true,
      );

      final modified = original.copyWith(
        language: 'hi',
        notifications: false,
      );

      expect(modified.language, equals('hi'));
      expect(modified.chartStyle, equals(original.chartStyle));
      expect(modified.notifications, isFalse);
    });
  });

  group('FirestoreService - Real-time Listeners', () {
    test('watchReport should throw StateError when not initialized', () {
      final service = FirestoreService.instance;

      expect(
        () => service.watchReport('test-report-id'),
        throwsStateError,
      );
    });

    test('watchUserReports should throw StateError when not initialized', () {
      final service = FirestoreService.instance;

      expect(
        () => service.watchUserReports('test-user-id'),
        throwsStateError,
      );
    });

    test(
        'watchUserReportsByStatus should throw StateError when not initialized',
        () {
      final service = FirestoreService.instance;

      expect(
        () => service.watchUserReportsByStatus(
          'test-user-id',
          ServiceReportStatus.completed,
        ),
        throwsStateError,
      );
    });

    test('watchUserProfile should throw StateError when not initialized', () {
      final service = FirestoreService.instance;

      expect(
        () => service.watchUserProfile('test-user-id'),
        throwsStateError,
      );
    });

    test('watchUserOrders should throw StateError when not initialized', () {
      final service = FirestoreService.instance;

      expect(
        () => service.watchUserOrders('test-user-id'),
        throwsStateError,
      );
    });

    test('watchOrder should throw StateError when not initialized', () {
      final service = FirestoreService.instance;

      expect(
        () => service.watchOrder('test-order-id'),
        throwsStateError,
      );
    });
  });

  group('FirestoreService - Pagination Logic', () {
    test('getUserReports should throw StateError when not initialized', () {
      final service = FirestoreService.instance;

      // Should throw StateError when Firebase is not initialized
      expect(
        () => service.getUserReports('test-user-id', limit: 10),
        throwsStateError,
      );
    });

    test(
        'getUserReports with startAfter should throw StateError when not initialized',
        () {
      final service = FirestoreService.instance;

      // Should throw StateError when Firebase is not initialized
      expect(
        () => service.getUserReports('test-user-id', startAfter: null),
        throwsStateError,
      );
    });

    test('getUserOrders should throw StateError when not initialized', () {
      final service = FirestoreService.instance;

      // Should throw StateError when Firebase is not initialized
      expect(
        () =>
            service.getUserOrders('test-user-id', limit: 10, startAfter: null),
        throwsStateError,
      );
    });
  });

  group('FirestoreService - Error Handling', () {
    test('should handle null values in model creation gracefully', () {
      // Test UserProfile with minimal data
      expect(
        () => UserProfile(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        returnsNormally,
      );

      // Test ServiceReport with minimal data
      expect(
        () => ServiceReport(
          id: 'test-id',
          userId: 'user-id',
          serviceType: ServiceType.kundali,
          status: ServiceReportStatus.pending,
          createdAt: DateTime.now(),
        ),
        returnsNormally,
      );

      // Test FirebaseOrder with minimal data
      expect(
        () => FirebaseOrder(
          id: 'test-id',
          userId: 'user-id',
          serviceType: 'kundali',
          amount: 299.0,
          status: FirebaseOrderStatus.pending,
          createdAt: DateTime.now(),
        ),
        returnsNormally,
      );
    });

    test('should handle invalid enum strings gracefully', () {
      // Invalid status should default to pending
      expect(
        ServiceReportStatus.fromString('invalid'),
        equals(ServiceReportStatus.pending),
      );

      // Invalid service type should default to kundali
      expect(
        ServiceType.fromString('invalid'),
        equals(ServiceType.kundali),
      );

      // Invalid order status should default to pending
      expect(
        FirebaseOrderStatus.fromString('invalid'),
        equals(FirebaseOrderStatus.pending),
      );
    });

    test('should handle case-insensitive enum conversion', () {
      expect(
        ServiceReportStatus.fromString('COMPLETED'),
        equals(ServiceReportStatus.completed),
      );
      expect(
        ServiceReportStatus.fromString('Completed'),
        equals(ServiceReportStatus.completed),
      );

      expect(
        ServiceType.fromString('KUNDALI'),
        equals(ServiceType.kundali),
      );
      expect(
        ServiceType.fromString('Kundali'),
        equals(ServiceType.kundali),
      );

      expect(
        FirebaseOrderStatus.fromString('PAID'),
        equals(FirebaseOrderStatus.paid),
      );
      expect(
        FirebaseOrderStatus.fromString('Paid'),
        equals(FirebaseOrderStatus.paid),
      );
    });
  });

  group('FirestoreService - JSON Serialization', () {
    test('UserProfile should convert to JSON', () {
      final now = DateTime.now();
      final profile = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        name: 'Test User',
        phone: '+1234567890',
        createdAt: now,
        updatedAt: now,
      );

      final json = profile.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['email'], equals('test@example.com'));
      expect(json['name'], equals('Test User'));
      expect(json['phone'], equals('+1234567890'));
      expect(json['createdAt'], isA<String>());
      expect(json['updatedAt'], isA<String>());
      expect(json['subscription'], isA<Map>());
      expect(json['preferences'], isA<Map>());
    });

    test('ServiceReport should convert to JSON', () {
      final now = DateTime.now();
      final report = ServiceReport(
        id: 'test-id',
        userId: 'user-id',
        serviceType: ServiceType.kundali,
        status: ServiceReportStatus.completed,
        createdAt: now,
        completedAt: now,
        data: {'test': 'data'},
      );

      final json = report.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['userId'], equals('user-id'));
      expect(json['serviceType'], equals('kundali'));
      expect(json['status'], equals('completed'));
      expect(json['createdAt'], isA<String>());
      expect(json['completedAt'], isA<String>());
      expect(json['data'], isA<Map>());
    });

    test('FirebaseOrder should convert to JSON', () {
      final now = DateTime.now();
      final order = FirebaseOrder(
        id: 'test-id',
        userId: 'user-id',
        serviceType: 'kundali',
        amount: 299.0,
        currency: 'INR',
        status: FirebaseOrderStatus.paid,
        paymentId: 'payment-123',
        createdAt: now,
        paidAt: now,
      );

      final json = order.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['userId'], equals('user-id'));
      expect(json['serviceType'], equals('kundali'));
      expect(json['amount'], equals(299.0));
      expect(json['currency'], equals('INR'));
      expect(json['status'], equals('paid'));
      expect(json['paymentId'], equals('payment-123'));
      expect(json['createdAt'], isA<String>());
      expect(json['paidAt'], isA<String>());
    });
  });
}
