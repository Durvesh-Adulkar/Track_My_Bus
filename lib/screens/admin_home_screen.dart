// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import '../models/bus_stop.dart';
// import '../services/auth_service.dart';
// import '../services/stop_service.dart';
// import '../services/route_service.dart';
// import '../services/bus_service.dart';
// import '../services/request_service.dart';
//
// class AdminHomeScreen extends StatefulWidget {
//   const AdminHomeScreen({super.key});
//
//   @override
//   State<AdminHomeScreen> createState() => _AdminHomeScreenState();
// }
//
// class _AdminHomeScreenState extends State<AdminHomeScreen> {
//   final StopService _stopService = StopService();
//   final RouteService _routeService = RouteService();
//   final BusService _busService = BusService();
//   final RequestService _reqService = RequestService();
//
//   @override
//   void initState() {
//     super.initState();
//     _seedData();
//   }
//
//   Future<void> _seedData() async {
//     await _stopService.seedSampleStops();
//     await _routeService.seedSampleRoutes();
//     await _busService.seedSampleBuses();
//     if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sample data seeded!')));
//   }
//
//   Future<void> _downloadReport() async {
//     final requests = await _reqService.getAllRequests();  // List of maps
//     final csv = 'ID,User,Bus,Stop,Status,Distance\n' + requests.map((r) => '${r['id']},${r['userId']},${r['busId']},${r['stopId']},${r['status']},${r['distanceBusToStop']}').join('\n');
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/reports.csv');
//     await file.writeAsString(csv);
//     Share.shareXFiles([XFile(file.path)], text: 'Bus Requests Report');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Admin Panel'), actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => AuthService().logout())]),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           ElevatedButton(onPressed: _seedData, child: const Text('Seed Sample Data')),
//           ElevatedButton(onPressed: () => _showAddStopDialog(), child: const Text('Add Bus Stop')),
//           ElevatedButton(onPressed: () => _showAddRouteDialog(), child: const Text('Add Route')),
//           ElevatedButton(onPressed: () => _showAddBusDialog(), child: const Text('Add Bus')),
//           ElevatedButton(onPressed: _downloadReport, child: const Text('Download Requests Report')),
//           // Lists: Stops, Routes, Buses, Requests (use StreamBuilder)
//           StreamBuilder<List<BusStopModel>>(
//             stream: _stopService.getAllStops(),
//             builder: (context, snapshot) {
//               if (snapshot.hasData) {
//                 return ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: snapshot.data!.length,
//                   itemBuilder: (context, i) => ListTile(title: Text(snapshot.data![i].name)),
//                 );
//               }
//               return const Text('Loading...');
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showAddStopDialog() {
//     // Dialog with TextFields for name, lat, lng, desc
//     // On save: Add via _stopService.addStop(new BusStopModel(...))
//   }
//
// // Similar for _showAddRouteDialog, _showAddBusDialog (include driver assign)
// }
// lib/screens/admin_home_screen.dart - Fixed Version
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
import '../models/bus.dart';
import '../models/bus_stop.dart';
import '../models/route.dart';
import '../services/stop_service.dart';
import '../services/route_service.dart';
import '../services/bus_service.dart';
import '../services/request_service.dart';
import '../services/auth_service.dart';  // Added for logout

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final StopService _stopService = StopService();
  final RouteService _routeService = RouteService();
  final BusService _busService = BusService();
  final RequestService _reqService = RequestService();

  @override
  void initState() {
    super.initState();
    _seedData();
  }

  Future<void> _seedData() async {
    await _stopService.seedSampleStops();
    await _routeService.seedSampleRoutes();
    await _busService.seedSampleBuses();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sample data seeded!')),
      );
    }
  }

  Future<void> _downloadReport() async {
    final requests = await _reqService.getAllRequests();  // List<RequestModel>
    // Fixed: Access properties on RequestModel instead of map[]
    final csv = 'ID,UserId,BusId,StopId,Status,DistanceBusToStop\n' +
        requests
            .map((r) => '${r.id},${r.userId},${r.busId},${r.stopId},${r.status},${r.distanceBusToStop}')
            .join('\n');
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/reports.csv');
    await file.writeAsString(csv);
    // Share.shareXFiles([XFile(file.path)], text: 'Bus Requests Report');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ElevatedButton(
            onPressed: _seedData,
            child: const Text('Seed Sample Data'),
          ),
          ElevatedButton(
            onPressed: () => _showAddStopDialog(),
            child: const Text('Add Bus Stop'),
          ),
          ElevatedButton(
            onPressed: () => _showAddRouteDialog(),
            child: const Text('Add Route'),
          ),
          ElevatedButton(
            onPressed: () => _showAddBusDialog(),
            child: const Text('Add Bus'),
          ),
          ElevatedButton(
            onPressed: _downloadReport,
            child: const Text('Download Requests Report'),
          ),
          // Lists: Stops, Routes, Buses, Requests (use StreamBuilder)
          StreamBuilder<List<BusStopModel>>(
            stream: _stopService.getAllStops(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) =>
                      ListTile(title: Text(snapshot.data![i].name)),
                );
              }
              return const Text('Loading...');
            },
          ),
        ],
      ),
    );
  }

  // Implemented: Simple dialog for adding stop
  void _showAddStopDialog() {
    final nameController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();
    final descController = TextEditingController();
    final idController = TextEditingController(text: 'stopId_${DateTime.now().millisecondsSinceEpoch}');  // Auto-gen ID

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bus Stop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: idController, decoration: const InputDecoration(labelText: 'Stop ID')),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: latController, decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: TextInputType.number),
            TextField(controller: lngController, decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: TextInputType.number),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final lat = double.tryParse(latController.text) ?? 0.0;
              final lng = double.tryParse(lngController.text) ?? 0.0;
              final stop = BusStopModel(
                id: idController.text,
                name: nameController.text,
                location: {'lat': lat, 'lng': lng},
                description: descController.text,
                busesServing: [],
                sequenceInRoutes: {},
                createdAt: DateTime.now(),
              );
              await _stopService.addStop(stop);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stop added!')));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Implemented: Simple dialog for adding route
  void _showAddRouteDialog() {
    final nameController = TextEditingController();
    final stopsController = TextEditingController(text: 'stopId_1,stopId_2');  // Comma-separated
    final distanceController = TextEditingController();
    final timeController = TextEditingController();
    final idController = TextEditingController(text: 'routeId_${DateTime.now().millisecondsSinceEpoch}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Route'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: idController, decoration: const InputDecoration(labelText: 'Route ID')),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: stopsController, decoration: const InputDecoration(labelText: 'Stops (comma-separated IDs)')),
            TextField(controller: distanceController, decoration: const InputDecoration(labelText: 'Total Distance (KM)'), keyboardType: TextInputType.number),
            TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Estimated Time (Min)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final distance = double.tryParse(distanceController.text) ?? 0.0;
              final time = int.tryParse(timeController.text) ?? 0;
              final stops = stopsController.text.split(',').map((s) => s.trim()).toList();
              final route = RouteModel(
                id: idController.text,
                name: nameController.text,
                stops: stops,
                totalDistance: distance,
                estimatedTime: time,
                createdAt: DateTime.now(),
              );
              await _routeService.addOrUpdateRoute(route);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Route added!')));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Implemented: Simple dialog for adding bus
  void _showAddBusDialog() {
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final driverIdController = TextEditingController();
    final routeIdController = TextEditingController();
    final capacityController = TextEditingController();
    final idController = TextEditingController(text: 'busId_${DateTime.now().millisecondsSinceEpoch}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bus'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: idController, decoration: const InputDecoration(labelText: 'Bus ID')),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: numberController, decoration: const InputDecoration(labelText: 'Number (License)')),
            TextField(controller: driverIdController, decoration: const InputDecoration(labelText: 'Driver ID')),
            TextField(controller: routeIdController, decoration: const InputDecoration(labelText: 'Route ID')),
            TextField(controller: capacityController, decoration: const InputDecoration(labelText: 'Capacity'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final capacity = int.tryParse(capacityController.text) ?? 0;
              final bus = BusModel(
                id: idController.text,
                name: nameController.text,
                number: numberController.text,
                driverId: driverIdController.text,
                routeId: routeIdController.text,
                route: [],  // Set later or from route
                currentStopIndex: 0,
                capacity: capacity,
                currentPassengers: 0,
                status: 'offline',
                currentLocation: {'lat': 0.0, 'lng': 0.0},
                etaToNextStop: 0.0,
                lastUpdated: DateTime.now(),
              );
              await _busService.addOrUpdateBus(bus);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bus added!')));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}