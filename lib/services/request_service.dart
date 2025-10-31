// lib/services/request_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request.dart';  // Assume RequestModel
import 'location_service.dart';  // For distance calcs
import '../services/bus_service.dart';  // To update passengers

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locService = LocationService();
  final BusService _busService = BusService();

  // Get all requests stream
  Stream<List<RequestModel>> getAllRequestsStream() {
    return _firestore.collection('requests').orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => RequestModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Get pending requests for bus (Driver dashboard)
  Stream<List<RequestModel>> getPendingRequestsStream(String busId) {
    return _firestore
        .collection('requests')
        .where('busId', isEqualTo: busId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RequestModel.fromMap(doc.data(), doc.id)).toList());
  }

  // Get user's requests
  Stream<List<RequestModel>> getUserRequestsStream(String userId) {
    return _firestore
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RequestModel.fromMap(doc.data(), doc.id)).toList());
  }

  // Send new request
  Future<void> sendRequest({
    required String userId,
    required String busId,
    required String stopId,
    required Map<String, double> userLocation,
    String notes = '',
  }) async {
    // Get bus and stop for distances
    final bus = await _busService.getBus(busId);
    final stopDoc = await _firestore.collection('bus_stops').doc(stopId).get();
    final stopLocation = Map<String, double>.from(stopDoc.data()?['location'] ?? {});

    final busLoc = bus?.currentLocation ?? {'lat': 0.0, 'lng': 0.0};
    final distanceBusToStop = _locService.calculateDistance(
      busLoc['lat']!, busLoc['lng']!, stopLocation['lat']!, stopLocation['lng']!,
    );
    final distanceStopToUser = _locService.calculateDistance(
      stopLocation['lat']!, stopLocation['lng']!, userLocation['lat']!, userLocation['lng']!,
    );

    final requestId = _firestore.collection('requests').doc().id;  // Auto ID
    await _firestore.collection('requests').doc(requestId).set({
      'userId': userId,
      'busId': busId,
      'stopId': stopId,
      'userLocationAtRequest': userLocation,
      'status': 'pending',
      'notes': notes,
      'distanceBusToStop': distanceBusToStop,
      'distanceStopToUser': distanceStopToUser,
      'timestamp': FieldValue.serverTimestamp(),
      'acceptedAt': null,
    });
  }

  // Accept request (Driver)
  Future<void> acceptRequest(String requestId) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
    // Update bus passengers
    final reqDoc = await _firestore.collection('requests').doc(requestId).get();
    final busId = reqDoc.data()?['busId'];
    await _busService.updatePassengers(busId, true);
  }

  // Reject request
  Future<void> rejectRequest(String requestId) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': 'rejected',
      'acceptedAt': null,
    });
  }

  // Cancel request (User)
  Future<void> cancelRequest(String requestId) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': 'cancelled',
    });
    // If was accepted, decrement passengers
    final reqDoc = await _firestore.collection('requests').doc(requestId).get();
    if (reqDoc.data()?['status'] == 'accepted') {
      final busId = reqDoc.data()?['busId'];
      await _busService.updatePassengers(busId, false);
    }
  }

  // Get all requests for report (Admin)
  Future<List<RequestModel>> getAllRequests() async {
    final snapshot = await _firestore.collection('requests').get();
    return snapshot.docs.map((doc) => RequestModel.fromMap(doc.data()!, doc.id)).toList();
  }
}