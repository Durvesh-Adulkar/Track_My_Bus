// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
//
// import '../models/bus.dart';
// import '../models/live_location.dart';
// import '../services/stop_service.dart';
// import '../services/bus_service.dart';
// import '../services/location_service.dart';
// import '../services/auth_service.dart';
//
// class PassengerHomeScreen extends StatefulWidget {
//   const PassengerHomeScreen({super.key});
//
//   @override
//   State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
// }
//
// class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
//   final StopService _stopService = StopService();
//   final BusService _busService = BusService();
//   final LocationService _locService = LocationService();
//   final AuthService _authService = AuthService();
//
//   GoogleMapController? _mapController;
//   Set<Marker> _markers = {};
//   String? _selectedStopId;
//   List<BusModel> _nearbyBuses = [];
//   late Position _userPosition;
//
//   // FIXED: Cache live locations to avoid repeated async calls in build()
//   Map<String, LiveLocationModel?> _liveCache = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocationAndUpdateMap();
//     // FIXED: Move stream listener to initState for proper lifecycle
//     _busService.getActiveBusesStream().listen(_onBusesUpdated);
//   }
//
//   Future<void> _getCurrentLocationAndUpdateMap() async {
//     _userPosition = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     _mapController?.animateCamera(
//       CameraUpdate.newLatLng(
//         LatLng(_userPosition.latitude, _userPosition.longitude),
//       ),
//     );
//     // FIXED: Add initial user marker and trigger empty update to set markers (stream will update buses soon after)
//     _onBusesUpdated([]); // This adds user marker and clears any stale markers
//   }
//
//   // FIXED: Separate callback for stream emissions – clears/rebuilds markers each time
//   void _onBusesUpdated(List<BusModel> buses) async {
//     final List<BusModel> nearby = [];
//     _markers.clear();
//
//     // Add user marker
//     _markers.add(
//       Marker(
//         markerId: const MarkerId('user'),
//         position: LatLng(_userPosition.latitude, _userPosition.longitude),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//       ),
//     );
//
//     // Process buses
//     for (final bus in buses) {
//       LiveLocationModel? live = _liveCache[bus.id];
//       if (live == null) {
//         live = await _busService.getLiveLocation(bus.id);
//         _liveCache[bus.id] = live; // Cache it
//       }
//
//       if (live == null) continue;
//
//       final distance = _locService.calculateDistance(
//         _userPosition.latitude,
//         _userPosition.longitude,
//         live.lat,
//         live.lng,
//       );
//
//       if (distance <= 500) {
//         _markers.add(
//           Marker(
//             markerId: MarkerId(bus.id),
//             position: LatLng(live.lat, live.lng),
//             infoWindow: InfoWindow(
//               title: bus.name,
//               snippet: '${bus.etaToNextStop.toStringAsFixed(0)} min to next stop',
//             ),
//           ),
//         );
//         nearby.add(bus);
//       }
//     }
//
//     if (mounted) {
//       setState(() {
//         _nearbyBuses = nearby;
//         // FIXED: Trigger map/markers rebuild via setState
//       });
//     }
//   }
//
//   void _searchStop(String stopName) {
//     // TODO: query StopService, show dialog, set _selectedStopId
//   }
//
//   void _sendRequest(String busId, String stopId) {
//     // TODO: push to Firestore /requests collection
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Pickup request sent!')),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Passenger – Track Buses'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () => _authService.logout(),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // ---- search bar ----
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               onChanged: _searchStop,
//               decoration: const InputDecoration(
//                 labelText: 'Search Stop (e.g., Kadamwadi)',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//
//           // ---- map ----
//           Expanded(
//             flex: 2,
//             child: GoogleMap(
//               onMapCreated: (c) => _mapController = c,
//               initialCameraPosition: const CameraPosition(
//                 target: LatLng(16.70, 74.21),
//                 zoom: 12,
//               ),
//               markers: _markers,
//               myLocationEnabled: true,
//               myLocationButtonEnabled: true,
//             ),
//           ),
//
//           // ---- nearby buses list ----
//           Expanded(
//             flex: 1,
//             child: ListView.builder(
//               itemCount: _nearbyBuses.length,
//               itemBuilder: (context, i) {
//                 final bus = _nearbyBuses[i];
//                 final live = _liveCache[bus.id]; // FIXED: Use cache instead of async in build
//                 if (live == null) return const SizedBox(); // Fallback if not loaded yet
//                 final distance = _locService.calculateDistance(
//                   _userPosition.latitude,
//                   _userPosition.longitude,
//                   live.lat,
//                   live.lng,
//                 );
//                 return ListTile(
//                   title: Text(bus.name),
//                   subtitle: Text('Distance: ${distance.toStringAsFixed(0)} m'),
//                   trailing: ElevatedButton(
//                     onPressed: _selectedStopId == null
//                         ? null
//                         : () => _sendRequest(bus.id, _selectedStopId!),
//                     child: const Text('Request Pickup'),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../models/bus.dart';
import '../models/live_location.dart';
import '../services/stop_service.dart';
import '../services/bus_service.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final StopService _stopService = StopService();
  final BusService _busService = BusService();
  final LocationService _locService = LocationService();
  final AuthService _authService = AuthService();

  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  List<BusModel> _nearbyBuses = [];
  Map<String, LiveLocationModel?> _liveCache = {};
  String? _selectedStopId;

  Position? _userPosition;
  bool _isLoading = true;
  bool _mapReady = false; // ✅ Tracks map ready state

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchUserLocation();

    // ✅ Start listening to bus updates only after location is fetched
    _busService.getActiveBusesStream().listen(_onBusesUpdated);
  }

  Future<void> _fetchUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _userPosition = position;
        _isLoading = false;
      });

      _updateUserMarker();

      // ✅ Move camera once map is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapReady = true;
        _moveCameraToUser();
      });
    } catch (e) {
      debugPrint('Location Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _moveCameraToUser() {
    if (_userPosition == null || !_mapReady) return;

    _mapController.move(
      LatLng(_userPosition!.latitude, _userPosition!.longitude),
      14.0,
    );
  }

  void _updateUserMarker() {
    if (_userPosition == null) return;

    setState(() {
      _markers = [
        Marker(
          point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          width: 40,
          height: 40,
          child: const Icon(Icons.person_pin_circle,
              color: Colors.blue, size: 40),
        ),
      ];
    });
  }

  void _onBusesUpdated(List<BusModel> buses) async {
    if (_userPosition == null) return;

    final List<BusModel> nearby = [];
    final List<Marker> markerList = [];

    // ✅ User marker always first
    markerList.add(
      Marker(
        point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
        width: 40,
        height: 40,
        child: const Icon(Icons.person_pin_circle,
            color: Colors.blue, size: 40),
      ),
    );

    for (final bus in buses) {
      LiveLocationModel? live = _liveCache[bus.id];

      if (live == null) {
        live = await _busService.getLiveLocation(bus.id);
        _liveCache[bus.id] = live;
      }

      if (live == null) continue;

      final distance = _locService.calculateDistance(
        _userPosition!.latitude,
        _userPosition!.longitude,
        live.lat,
        live.lng,
      );

      if (distance <= 500) {
        markerList.add(
          Marker(
            point: LatLng(live.lat, live.lng),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${bus.name} → ${bus.etaToNextStop.toStringAsFixed(0)} min'),
                  duration: const Duration(seconds: 2),
                ),
              ),
              child: const Icon(Icons.directions_bus,
                  color: Colors.red, size: 40),
            ),
          ),
        );
        nearby.add(bus);
      }
    }

    if (!mounted) return;

    setState(() {
      _nearbyBuses = nearby;
      _markers = markerList;
    });
  }

  void _searchStop(String stopName) {
    // TODO Search implementation later
  }

  void _sendRequest(String busId, String stopId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pickup request sent to bus $busId')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passenger – Track Bus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.logout(),
          )
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchStop,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                labelText: 'Search Stop Name',
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(16.70, 74.21),
                initialZoom: 12,
                minZoom: 5,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.track_my_bus',
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
          ),

          Expanded(
            flex: 1,
            child: _nearbyBuses.isEmpty
                ? const Center(
                child: Text('No buses nearby (within 500m)',
                    style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                itemCount: _nearbyBuses.length,
                itemBuilder: (context, i) {
                  final bus = _nearbyBuses[i];
                  final live = _liveCache[bus.id];
                  final distance =
                  _locService.calculateDistance(
                    _userPosition!.latitude,
                    _userPosition!.longitude,
                    live!.lat,
                    live.lng,
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.directions_bus,
                          color: Colors.red),
                      title: Text(bus.name),
                      subtitle: Text(
                          '${distance.toStringAsFixed(0)} m away'),
                      trailing: ElevatedButton(
                        onPressed: _selectedStopId == null
                            ? null
                            : () =>
                            _sendRequest(bus.id, _selectedStopId!),
                        child: const Text('Request'),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),

      floatingActionButton: _userPosition == null
          ? null
          : FloatingActionButton(
        onPressed: _moveCameraToUser,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
