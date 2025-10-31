// lib/services/bus_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/bus.dart'; // Assume BusModel is defined
import '../models/live_location.dart'; // Assume LiveLocationModel
import 'location_service.dart'; // For distance/ETA calcs

class BusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locService = LocationService();

  // Get all active buses stream
  Stream<List<BusModel>> getActiveBusesStream() {
    return _firestore
        .collection('buses')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => BusModel.fromMap(doc.data()!, doc.id)).toList());
  }

  // Get bus by ID
  Future<BusModel?> getBus(String busId) async {
    final doc = await _firestore.collection('buses').doc(busId).get();
    if (doc.exists) {
      return BusModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Get live location for bus (stream)
  // Stream<LiveLocationModel?> getLiveLocationStream(String busId) {
  //   return _firestore.collection('live_locations').doc(busId).snapshots().map((snapshot) {
  //     if (snapshot.exists) {
  //       return LiveLocationModel.fromMap(snapshot.data()!, busId);
  //     }
  //     return null;
  //   });
  // }

  // lib/services/bus_service.dart  (add at the end of the class)

  /// Returns the most-recent live location for a bus (null if none yet).
  Future<LiveLocationModel?> getLiveLocation(String busId) async {
    final snap = await _firestore.collection('live_locations').doc(busId).get();
    if (snap.exists) {
      return LiveLocationModel.fromMap(snap.data()!, busId);
    }
    return null;
  }

  // Update bus status
  Future<void> updateBusStatus(String busId, String status) async {
    await _firestore.collection('buses').doc(busId).update({
      'status': status,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Update current passengers (+1 or -1)
  Future<void> updatePassengers(String busId, bool increment) async {
    final change = increment ? 1 : -1;
    await _firestore.collection('buses').doc(busId).update({
      'currentPassengers': FieldValue.increment(change),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Update ETA to next stop (simple calc: distance / speed)
  Future<void> updateEtaToNextStop(String busId, double etaMinutes) async {
    await _firestore.collection('buses').doc(busId).update({
      'etaToNextStop': etaMinutes,
    });
  }

  // Add or update bus (Admin/Driver)
  Future<void> addOrUpdateBus(BusModel bus) async {
    await _firestore.collection('buses').doc(bus.id).set(bus.toMap());
    // Also update busesServing in stops
    for (String stopId in bus.route) {
      await _firestore.collection('bus_stops').doc(stopId).update({
        'busesServing': FieldValue.arrayUnion([bus.id]),
      });
    }
  }

  // Seed sample buses
  Future<void> seedSampleBuses() async {
    final busesRef = _firestore.collection('buses');
    final snapshot = await busesRef.get();
    if (snapshot.docs.isEmpty) {
      await busesRef.doc('busId_123').set({
        'name': 'Kadamwadi to Pachgaon',
        'number': 'MH-12-AB-1234',
        'driverId': 'driverId_001', // Assume driver exists
        'routeId': 'routeId_001',
        'route': ['stopId_1', 'stopId_2', 'stopId_3'],
        'currentStopIndex': 0,
        'capacity': 50,
        'currentPassengers': 0,
        'status': 'offline',
        'currentLocation': {'lat': 16.70, 'lng': 74.21},
        'etaToNextStop': 0,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      // Add more buses here if needed
    }
  }

  // Get bus status (helper)
  Future<String> getBusStatus(String busId) async {
    final bus = await getBus(busId);
    return bus?.status ?? 'unknown';
  }

  // Filter nearby buses (call from passenger screen)
  Future<List<BusModel>> getNearbyBuses(double userLat, double userLng, {double maxDistance = 500}) async {
    final busesSnapshot = await getActiveBusesStream().first; // Await the Future<List>
    return busesSnapshot.where((bus) {
      // Use bus.currentLocation (mirrors live_locations) for sync distance calc
      // Handle potential nulls from map access
      final busLat = bus.currentLocation['lat'] ?? 0.0;
      final busLng = bus.currentLocation['lng'] ?? 0.0;
      final dist = _locService.calculateDistance(userLat, userLng, busLat, busLng);
      return dist <= maxDistance;
    }).toList();
  }
}