// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import '../services/auth_service.dart';
// import '../services/bus_service.dart';
// import '../services/location_service.dart';
// import '../services/request_service.dart';
//
// class DriverHomeScreen extends StatefulWidget {
//   const DriverHomeScreen({super.key});
//
//   @override
//   State<DriverHomeScreen> createState() => _DriverHomeScreenState();
// }
//
// class _DriverHomeScreenState extends State<DriverHomeScreen> {
//   final BusService _busService = BusService();
//   final RequestService _reqService = RequestService();
//   final LocationService _locService = LocationService();
//   GoogleMapController? _mapController;
//   Timer? _locationTimer;
//   bool _isTracking = false;
//   String? _assignedBusId; // Fetch from user doc
//   List<dynamic> _pendingRequests = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchAssignedBus();
//     _reqService
//         .getPendingRequestsStream(_assignedBusId!)
//         .listen((reqs) => setState(() => _pendingRequests = reqs));
//   }
//
//   Future<void> _fetchAssignedBus() async {
//     // Query user doc for assignedBus
//     _assignedBusId = 'busId_123'; // Sample
//   }
//
//   void _startTracking() {
//     setState(() => _isTracking = true);
//     _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
//       Position pos = await Geolocator.getCurrentPosition();
//       await _locService.updateLiveLocation(
//         _assignedBusId!,
//         pos.latitude,
//         pos.longitude,
//         25.0,
//         90,
//       ); // speed, heading
//       _mapController?.animateCamera(
//         CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
//       );
//     });
//   }
//
//   void _stopTracking() {
//     _locationTimer?.cancel();
//     setState(() => _isTracking = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Driver Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () => AuthService().logout(),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Row(
//             children: [
//               ElevatedButton(
//                 onPressed: _isTracking ? _stopTracking : _startTracking,
//                 child: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
//               ),
//               const Spacer(),
//               Text(
//                 'Status: ${_busService.getBusStatus(_assignedBusId!)}',
//               ), // active/offline
//             ],
//           ),
//           Expanded(
//             child: GoogleMap(
//               onMapCreated: (controller) => _mapController = controller,
//               initialCameraPosition: const CameraPosition(
//                 target: LatLng(16.70, 74.21),
//                 zoom: 12,
//               ),
//               myLocationEnabled: true,
//             ),
//           ),
//           // Pending requests list
//           Expanded(
//             child: ListView.builder(
//               itemCount: _pendingRequests.length,
//               itemBuilder:
//                   (context, i) => ListTile(
//                     title: Text(
//                       'Request from ${_pendingRequests[i]['userName']}',
//                     ), // Fetch name
//                     subtitle: Text('At ${_pendingRequests[i]['stopName']}'),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.check),
//                           onPressed:
//                               () => _acceptRequest(_pendingRequests[i]['id']),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.close),
//                           onPressed:
//                               () => _rejectRequest(_pendingRequests[i]['id']),
//                         ),
//                       ],
//                     ),
//                   ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _acceptRequest(String reqId) {
//     _reqService.acceptRequest(reqId);
//     _busService.updatePassengers(_assignedBusId!, true); // +1
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Accepted!')));
//   }
//
//   void _rejectRequest(String reqId) {
//     _reqService.rejectRequest(reqId);
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Rejected')));
//   }
//
//   @override
//   void dispose() {
//     _locationTimer?.cancel();
//     super.dispose();
//   }
// }

// lib/screens/driver_home_screen.dart - Fixed Version (Key Changes: Named args in updateLiveLocation; Null-safe _assignedBusId; Fetch names for requests; Await init)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/auth_service.dart';
import '../services/bus_service.dart';
import '../services/location_service.dart';
import '../services/request_service.dart';
import '../models/request.dart';  // For RequestModel access

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final BusService _busService = BusService();
  final RequestService _reqService = RequestService();
  final LocationService _locService = LocationService();
  GoogleMapController? _mapController;
  Timer? _locationTimer;
  bool _isTracking = false;
  String? _assignedBusId; // Fetch from user doc
  List<RequestModel> _pendingRequests = [];  // Typed as List<RequestModel>

  @override
  void initState() {
    super.initState();
    _initData();  // New: Await fetch before stream
  }

  Future<void> _initData() async {
    await _fetchAssignedBus();
    if (_assignedBusId != null) {
      _reqService
          .getPendingRequestsStream(_assignedBusId!)
          .listen((reqs) => setState(() => _pendingRequests = reqs));
    }
    setState(() {});  // Refresh UI
  }

  Future<void> _fetchAssignedBus() async {
    // Query user doc for assignedBus (replace with real fetch)
    _assignedBusId = 'busId_123'; // Sample - in prod: await FirebaseFirestore... get user.assignedBus
  }

  void _startTracking() {
    if (_assignedBusId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No bus assigned!')));
      return;
    }
    setState(() => _isTracking = true);
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      Position pos = await Geolocator.getCurrentPosition();
      await _locService.updateLiveLocation(
        _assignedBusId!,
        pos.latitude,
        pos.longitude,
        speed: 25.0,  // Fixed: Named args for speed/heading
        heading: 90,
      );
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
      );
    });
  }

  void _stopTracking() {
    _locationTimer?.cancel();
    setState(() => _isTracking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: _isTracking ? _stopTracking : _startTracking,
                child: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
              ),
              const Spacer(),
              Text(
                'Status: ${_assignedBusId != null ? _busService.getBusStatus(_assignedBusId!) : 'Unknown'}',  // Null-safe
              ),
            ],
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: const CameraPosition(
                target: LatLng(16.70, 74.21),
                zoom: 12,
              ),
              myLocationEnabled: true,
            ),
          ),
          // Pending requests list
          Expanded(
            child: ListView.builder(
              itemCount: _pendingRequests.length,
              itemBuilder: (context, i) {
                final req = _pendingRequests[i];
                return ListTile(
                  title: Text('Request from ${req.userId}'),  // Fixed: Use model props (fetch full name in prod via user query)
                  subtitle: Text('At ${req.stopId}'),  // Fixed: Use stopId (fetch name in prod)
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () => _acceptRequest(req.id),  // Fixed: req.id
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _rejectRequest(req.id),  // Fixed: req.id
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _acceptRequest(String reqId) {
    _reqService.acceptRequest(reqId);
    if (_assignedBusId != null) {
      _busService.updatePassengers(_assignedBusId!, true); // +1, null-safe
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accepted!')));
  }

  void _rejectRequest(String reqId) {
    _reqService.rejectRequest(reqId);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejected')));
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
}