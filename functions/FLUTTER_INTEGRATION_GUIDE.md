# Flutter Integration Guide for Cloud Functions

This guide helps Flutter developers integrate with the deployed Cloud Functions.

## Prerequisites

Ensure your Flutter app has the Firebase Functions package:

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^latest
  cloud_functions: ^latest
```

## Initialize Firebase Functions

```dart
import 'package:cloud_functions/cloud_functions.dart';

// Get Functions instance
final functions = FirebaseFunctions.instance;

// For development/testing with emulator (optional)
// functions.useFunctionsEmulator('localhost', 5001);
```

## 1. Health Check

Test if Cloud Functions are accessible:

```dart
Future<void> testHealthCheck() async {
  try {
    final response = await http.get(
      Uri.parse('https://healthcheck-sc3sf53zda-uc.a.run.app'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Health Check: ${data['status']}');
      print('Message: ${data['message']}');
    }
  } catch (e) {
    print('Health check failed: $e');
  }
}
```

## 2. Generate Kundali (Instant)

```dart
Future<Map<String, dynamic>> generateKundali({
  required String name,
  required String dateOfBirth, // YYYY-MM-DD
  required String timeOfBirth, // HH:MM (24-hour)
  required String placeOfBirth,
  required double latitude,
  required double longitude,
  String chartStyle = 'northIndian',
}) async {
  try {
    final callable = functions.httpsCallable('generateKundali');
    
    final result = await callable.call({
      'name': name,
      'dateOfBirth': dateOfBirth,
      'timeOfBirth': timeOfBirth,
      'placeOfBirth': placeOfBirth,
      'latitude': latitude,
      'longitude': longitude,
      'chartStyle': chartStyle,
    });
    
    return result.data as Map<String, dynamic>;
  } on FirebaseFunctionsException catch (e) {
    print('Error: ${e.code} - ${e.message}');
    rethrow;
  }
}

// Usage Example
final result = await generateKundali(
  name: 'John Doe',
  dateOfBirth: '1990-01-15',
  timeOfBirth: '10:30',
  placeOfBirth: 'Mumbai',
  latitude: 19.0760,
  longitude: 72.8777,
  chartStyle: 'northIndian',
);

print('Report ID: ${result['reportId']}');
print('Status: ${result['status']}');
print('PDF URL: ${result['files']['pdfUrl']}');
print('Chart URL: ${result['files']['chartImageUrl']}');
```

## 3. Request Palmistry Analysis (24-hour delay)

```dart
Future<Map<String, dynamic>> requestPalmistryAnalysis({
  required String imageUrl,
  String handType = 'right',
  String analysisType = 'detailed',
  List<String>? specificQuestions,
}) async {
  try {
    final callable = functions.httpsCallable('requestPalmistryAnalysis');
    
    final result = await callable.call({
      'imageUrl': imageUrl,
      'handType': handType,
      'analysisType': analysisType,
      'specificQuestions': specificQuestions ?? [],
    });
    
    return result.data as Map<String, dynamic>;
  } on FirebaseFunctionsException catch (e) {
    print('Error: ${e.code} - ${e.message}');
    rethrow;
  }
}

// Usage Example
final result = await requestPalmistryAnalysis(
  imageUrl: 'https://storage.googleapis.com/...',
  handType: 'right',
  analysisType: 'detailed',
);

print('Report ID: ${result['reportId']}');
print('Status: ${result['status']}'); // 'scheduled'
print('Estimated Delivery: ${result['estimatedDelivery']}');
```

## 4. Request Numerology Report (12-hour delay)

```dart
Future<Map<String, dynamic>> requestNumerologyReport({
  required String name,
  required String dateOfBirth, // YYYY-MM-DD
  String reportType = 'detailed',
  bool includeCompatibility = false,
  String? partnerDateOfBirth,
}) async {
  try {
    final callable = functions.httpsCallable('requestNumerologyReport');
    
    final result = await callable.call({
      'name': name,
      'dateOfBirth': dateOfBirth,
      'reportType': reportType,
      'includeCompatibility': includeCompatibility,
      'partnerDateOfBirth': partnerDateOfBirth,
    });
    
    return result.data as Map<String, dynamic>;
  } on FirebaseFunctionsException catch (e) {
    print('Error: ${e.code} - ${e.message}');
    rethrow;
  }
}

// Usage Example
final result = await requestNumerologyReport(
  name: 'John Doe',
  dateOfBirth: '1990-01-15',
  reportType: 'comprehensive',
);

print('Report ID: ${result['reportId']}');
print('Status: ${result['status']}'); // 'scheduled'
print('Estimated Delivery: ${result['estimatedDelivery']}');
```

## 5. Process Payment

```dart
Future<Map<String, dynamic>> processPayment({
  required String orderId,
  required String paymentId,
  required String paymentGateway, // 'razorpay' or 'stripe'
  required double amount,
  required String currency,
  String? signature, // For Razorpay
  String? paymentIntentId, // For Stripe
}) async {
  try {
    final callable = functions.httpsCallable('processPayment');
    
    final result = await callable.call({
      'orderId': orderId,
      'paymentId': paymentId,
      'paymentGateway': paymentGateway,
      'amount': amount,
      'currency': currency,
      'signature': signature,
      'paymentIntentId': paymentIntentId,
    });
    
    return result.data as Map<String, dynamic>;
  } on FirebaseFunctionsException catch (e) {
    print('Error: ${e.code} - ${e.message}');
    rethrow;
  }
}

// Usage Example (Razorpay)
final result = await processPayment(
  orderId: 'order_123',
  paymentId: 'pay_456',
  paymentGateway: 'razorpay',
  amount: 299.00,
  currency: 'INR',
  signature: 'razorpay_signature_here',
);

print('Payment Status: ${result['status']}');
print('Report ID: ${result['reportId']}');
```

## 6. Listen to Report Status (Real-time)

Use Firestore to listen for real-time updates:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Stream<DocumentSnapshot> watchReport(String reportId) {
  return FirebaseFirestore.instance
      .collection('reports')
      .doc(reportId)
      .snapshots();
}

// Usage Example
watchReport(reportId).listen((snapshot) {
  if (snapshot.exists) {
    final data = snapshot.data() as Map<String, dynamic>;
    final status = data['status'];
    
    print('Report Status: $status');
    
    if (status == 'completed') {
      final pdfUrl = data['files']['pdfUrl'];
      print('Report ready! PDF: $pdfUrl');
      // Show notification or navigate to report screen
    } else if (status == 'failed') {
      final error = data['error']['message'];
      print('Report failed: $error');
      // Show error message
    }
  }
});
```

## Error Handling

All Cloud Functions return standardized errors:

```dart
try {
  final result = await generateKundali(...);
} on FirebaseFunctionsException catch (e) {
  switch (e.code) {
    case 'unauthenticated':
      // User not logged in
      print('Please log in to continue');
      break;
    case 'invalid-argument':
      // Invalid input data
      print('Invalid data: ${e.message}');
      break;
    case 'permission-denied':
      // User doesn't have permission
      print('Access denied');
      break;
    case 'not-found':
      // Resource not found
      print('Not found: ${e.message}');
      break;
    case 'deadline-exceeded':
      // Request timeout
      print('Request timed out. Please try again.');
      break;
    case 'unavailable':
      // Service temporarily unavailable
      print('Service unavailable. Please try again later.');
      break;
    default:
      // Other errors
      print('Error: ${e.code} - ${e.message}');
  }
}
```

## Complete Service Class Example

```dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFunctionsService {
  final _functions = FirebaseFunctions.instance;
  final _firestore = FirebaseFirestore.instance;
  
  // Generate Kundali
  Future<Map<String, dynamic>> generateKundali({
    required String name,
    required String dateOfBirth,
    required String timeOfBirth,
    required String placeOfBirth,
    required double latitude,
    required double longitude,
    String chartStyle = 'northIndian',
  }) async {
    final callable = _functions.httpsCallable('generateKundali');
    final result = await callable.call({
      'name': name,
      'dateOfBirth': dateOfBirth,
      'timeOfBirth': timeOfBirth,
      'placeOfBirth': placeOfBirth,
      'latitude': latitude,
      'longitude': longitude,
      'chartStyle': chartStyle,
    });
    return result.data as Map<String, dynamic>;
  }
  
  // Request Palmistry Analysis
  Future<Map<String, dynamic>> requestPalmistryAnalysis({
    required String imageUrl,
    String handType = 'right',
    String analysisType = 'detailed',
  }) async {
    final callable = _functions.httpsCallable('requestPalmistryAnalysis');
    final result = await callable.call({
      'imageUrl': imageUrl,
      'handType': handType,
      'analysisType': analysisType,
    });
    return result.data as Map<String, dynamic>;
  }
  
  // Request Numerology Report
  Future<Map<String, dynamic>> requestNumerologyReport({
    required String name,
    required String dateOfBirth,
    String reportType = 'detailed',
  }) async {
    final callable = _functions.httpsCallable('requestNumerologyReport');
    final result = await callable.call({
      'name': name,
      'dateOfBirth': dateOfBirth,
      'reportType': reportType,
    });
    return result.data as Map<String, dynamic>;
  }
  
  // Process Payment
  Future<Map<String, dynamic>> processPayment({
    required String orderId,
    required String paymentId,
    required String paymentGateway,
    required double amount,
    required String currency,
    String? signature,
  }) async {
    final callable = _functions.httpsCallable('processPayment');
    final result = await callable.call({
      'orderId': orderId,
      'paymentId': paymentId,
      'paymentGateway': paymentGateway,
      'amount': amount,
      'currency': currency,
      'signature': signature,
    });
    return result.data as Map<String, dynamic>;
  }
  
  // Watch report status
  Stream<DocumentSnapshot> watchReport(String reportId) {
    return _firestore.collection('reports').doc(reportId).snapshots();
  }
  
  // Get report
  Future<DocumentSnapshot> getReport(String reportId) {
    return _firestore.collection('reports').doc(reportId).get();
  }
}
```

## Testing Mode

For testing without payment:

1. Create an order in Firestore with `testMode: true`
2. The `onOrderCreated` trigger will auto-complete the order
3. Service will be processed automatically

```dart
// Create test order
await FirebaseFirestore.instance.collection('orders').add({
  'userId': currentUserId,
  'serviceType': 'kundali',
  'amount': 0,
  'currency': 'INR',
  'status': 'pending',
  'testMode': true,
  'createdAt': FieldValue.serverTimestamp(),
  'serviceData': {
    'name': 'Test User',
    'dateOfBirth': '1990-01-01',
    // ... other data
  },
});
```

## Important Notes

1. **Authentication Required**: All callable functions require Firebase Authentication
2. **Real-time Updates**: Use Firestore listeners for status updates
3. **Error Handling**: Always wrap function calls in try-catch
4. **Timeouts**: Kundali generation has 5-minute timeout, others have 1-minute
5. **Async Services**: Palmistry (24h) and Numerology (12h) are scheduled, not instant

## Support

For issues or questions:
- Check function logs: `firebase functions:log`
- Review Firebase Console: https://console.firebase.google.com/project/vagdishaajyoti/functions
- Refer to DEPLOYMENT.md for troubleshooting

## Function URLs

- **Health Check**: https://healthcheck-sc3sf53zda-uc.a.run.app
- **Other functions**: Use Firebase Functions SDK (callable functions)

---

**Last Updated**: October 28, 2025  
**Firebase Project**: vagdishaajyoti  
**Region**: us-central1
