// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// //
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //
// //   try {
// //     // Initialize Firebase using google-services.json
// //     await Firebase.initializeApp();
// //     runApp(const FirebaseConnectedApp());
// //   } catch (e) {
// //     runApp(FirebaseErrorApp(error: e.toString()));
// //   }
// // }
// //
// // class FirebaseConnectedApp extends StatelessWidget {
// //   const FirebaseConnectedApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Firebase Test',
// //       theme: ThemeData(primarySwatch: Colors.blue),
// //       home: const FirebaseCheckScreen(),
// //     );
// //   }
// // }
// //
// // class FirebaseCheckScreen extends StatefulWidget {
// //   const FirebaseCheckScreen({super.key});
// //
// //   @override
// //   State<FirebaseCheckScreen> createState() => _FirebaseCheckScreenState();
// // }
// //
// // class _FirebaseCheckScreenState extends State<FirebaseCheckScreen> {
// //   bool _connected = false;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _checkFirebase();
// //   }
// //
// //   Future<void> _checkFirebase() async {
// //     try {
// //       final app = Firebase.app();
// //       debugPrint("✅ Firebase connected: ${app.name}");
// //       setState(() => _connected = true);
// //     } catch (e) {
// //       debugPrint("❌ Firebase connection failed: $e");
// //       setState(() => _connected = false);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Firebase Connection Test')),
// //       body: Center(
// //         child: _connected
// //             ? const Icon(Icons.check_circle, color: Colors.green, size: 80)
// //             : const Icon(Icons.error, color: Colors.red, size: 80),
// //       ),
// //     );
// //   }
// // }
// //
// // class FirebaseErrorApp extends StatelessWidget {
// //   final String error;
// //   const FirebaseErrorApp({super.key, required this.error});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //         body: Center(
// //           child: Text(
// //             'Firebase initialization failed:\n$error',
// //             style: const TextStyle(fontSize: 16, color: Colors.red),
// //             textAlign: TextAlign.center,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: AddNameScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class AddNameScreen extends StatefulWidget {
//   const AddNameScreen({super.key});
//
//   @override
//   State<AddNameScreen> createState() => _AddNameScreenState();
// }
//
// class _AddNameScreenState extends State<AddNameScreen> {
//   final TextEditingController _nameController = TextEditingController();
//
//   Future<void> _addName() async {
//     final name = _nameController.text.trim();
//     if (name.isEmpty) return;
//
//     try {
//       await FirebaseFirestore.instance.collection('users').add({'name': name});
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('✅ Added "$name" successfully!')),
//       );
//       _nameController.clear();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('❌ Failed to add name: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Name to Firestore')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter your name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _addName,
//               child: const Text('Save to Firebase'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart';
// import 'screens/login_screen.dart';
// import 'screens/passenger_home_screen.dart';
// import 'screens/driver_home_screen.dart';
// import 'screens/admin_home_screen.dart';
// import 'services/auth_service.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   try {
//     if (Firebase.apps.isEmpty) {
//       await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform,
//       );
//       print('✅ Firebase initialized successfully');
//     } else {
//       print('⚠️ Firebase already initialized');
//     }
//   } catch (e) {
//     print('❌ Firebase initialization error: $e');
//   }
//
//   runApp(const MyApp());
// }
//
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           // ✅ if not sign-in → show login immediately
//           if (!snapshot.hasData) {
//             return const LoginScreen();
//           }
//
//           // ✅ user logged-in → fetch role
//           return FutureBuilder<String?>(
//             future: AuthService().getUserRole(snapshot.data!.uid),
//             builder: (context, roleSnapshot) {
//               if (roleSnapshot.connectionState == ConnectionState.waiting) {
//                 return const Scaffold(
//                   body: Center(child: CircularProgressIndicator()),
//                 );
//               }
//
//               final role = roleSnapshot.data;
//               if (role == 'passenger') return const PassengerHomeScreen();
//               if (role == 'driver') return const DriverHomeScreen();
//               if (role == 'admin') return const AdminHomeScreen();
//
//               return const LoginScreen();
//             },
//           );
//         },
//       ),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/passenger_home_screen.dart';
import 'screens/driver_home_screen.dart';
import 'screens/admin_home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully');
    } else {
      print('⚠️ Firebase already initialized');
    }
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {  // FIXED: Changed to StatefulWidget for retry functionality
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {  // FIXED: Defined _MyAppState
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // ✅ if not sign-in → show login immediately
          if (!snapshot.hasData) {
            return const LoginScreen();
          }

          // ✅ user logged-in → fetch role
          return FutureBuilder<String?>(
            future: AuthService().getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // FIXED: Add error handling/logging for role fetch failures
              if (roleSnapshot.hasError) {
                print('❌ Role fetch error: ${roleSnapshot.error}'); // Debug log
                // Show error screen with retry
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text('Error loading user role.', style: TextStyle(fontSize: 18)),
                        const Text('Retrying in a moment...'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}), // FIXED: Direct setState in _MyAppState (no need for findAncestor)
                          child: const Text('Retry Now'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final role = roleSnapshot.data;
              print('✅ Fetched role: $role for UID: ${snapshot.data!.uid}'); // Debug log
              if (role == 'passenger') return const PassengerHomeScreen();
              if (role == 'driver') return const DriverHomeScreen();
              if (role == 'admin') return const AdminHomeScreen();

              // FIXED: Log fallback to login
              print('⚠️ Unknown role or null: $role → Showing login');
              return const LoginScreen();
            },
          );
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
