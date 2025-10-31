// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import '../services/auth_service.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final AuthService _auth = AuthService();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   String _role = 'passenger';  // Dropdown: passenger, driver
//   bool _isSignup = false;
//   bool _isLoading = false;
//
//   Future<Map<String, double>?> _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return null;
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return null;
//     }
//     Position pos = await Geolocator.getCurrentPosition();
//     return {'lat': pos.latitude, 'lng': pos.longitude};
//   }
//
//   Future<void> _handleAuth() async {
//     setState(() => _isLoading = true);
//     try {
//       final location = await _getCurrentLocation();
//       if (_isSignup) {
//         // Signup
//         await _auth.createOrUpdateUser(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//           name: _nameController.text.trim(),
//           phone: _phoneController.text.trim(),
//           role: _role,
//           location: location,
//         );
//       } else {
//         // Login
//         if (_auth.isAdmin(_emailController.text.trim())) {
//           // Hardcoded admin - create if not exists
//           await _auth.createOrUpdateUser(
//             email: 'admin@example.com',
//             password: 'admin',
//             name: 'Admin',
//             phone: '0000000000',
//             role: 'admin',
//             location: location,
//           );
//           _emailController.text = 'admin@example.com';
//           _passwordController.text = 'admin';
//         }
//         await _auth.login(_emailController.text.trim(), _passwordController.text.trim());
//       }
//       if (mounted) Navigator.pushReplacementNamed(context, '/home');  // Auto-routes via main
//     } catch (e) {
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//     if (mounted) setState(() => _isLoading = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login / Signup')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
//             TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
//             if (_isSignup) ...[
//               TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
//               TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone')),
//               DropdownButton<String>(
//                 value: _role,
//                 onChanged: (val) => setState(() => _role = val!),
//                 items: ['passenger', 'driver'].map((r) => DropdownMenuItem(value: r, child: Text(r.capitalize()))).toList(),
//               ),
//             ],
//             const SizedBox(height: 16),
//             ElevatedButton(onPressed: _isLoading ? null : _handleAuth, child: Text(_isSignup ? 'Signup' : 'Login')),
//             TextButton(onPressed: () => setState(() => _isSignup = !_isSignup), child: Text(_isSignup ? 'Switch to Login' : 'Switch to Signup')),
//             if (_isLoading) const CircularProgressIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Extension for capitalize
// extension StringExtension on String {
//   String get capitalize => "${this[0].toUpperCase()}${substring(1)}";
// }
// lib/screens/login_screen.dart - Fixed (Key Change: r.capitalize without () as it's a getter)

//
//
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import '../services/auth_service.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final AuthService _auth = AuthService();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   String _role = 'passenger'; // Dropdown: passenger, driver
//   bool _isSignup = false;
//   bool _isLoading = false;
//
//   Future<Map<String, double>?> _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return null;
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return null;
//     }
//     Position pos = await Geolocator.getCurrentPosition();
//     return {'lat': pos.latitude, 'lng': pos.longitude};
//   }
//
//   Future<void> _handleAuth() async {
//     setState(() => _isLoading = true);
//     try {
//       final location = await _getCurrentLocation();
//       if (_isSignup) {
//         // Signup
//         await _auth.createOrUpdateUser(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//           name: _nameController.text.trim(),
//           phone: _phoneController.text.trim(),
//           role: _role,
//           location: location,
//         );
//       } else {
//         // Login
//         if (_auth.isAdmin(_emailController.text.trim())) {
//           // Hardcoded admin - create if not exists
//           await _auth.createOrUpdateUser(
//             email: 'admin@example.com',
//             password: 'admin',
//             name: 'Admin',
//             phone: '0000000000',
//             role: 'admin',
//             location: location,
//           );
//           _emailController.text = 'admin@example.com';
//           _passwordController.text = 'admin';
//         }
//         await _auth.login(
//           _emailController.text.trim(),
//           _passwordController.text.trim(),
//         );
//       }
//       if (mounted)
//         Navigator.pushReplacementNamed(
//           context,
//           '/home',
//         ); // Auto-routes via main
//     } catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//     if (mounted) setState(() => _isLoading = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login / Signup')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: 'Password'),
//             ),
//             if (_isSignup) ...[
//               TextField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: 'Name'),
//               ),
//               TextField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(labelText: 'Phone'),
//               ),
//               DropdownButton<String>(
//                 value: _role,
//                 onChanged: (val) => setState(() => _role = val!),
//                 items:
//                     ['passenger', 'driver']
//                         .map(
//                           (r) => DropdownMenuItem(
//                             value: r,
//                             child: Text(r.capitalize),
//                           ),
//                         )
//                         .toList(), // Fixed: No () on getter
//               ),
//             ],
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _handleAuth,
//               child: Text(_isSignup ? 'Signup' : 'Login'),
//             ),
//             TextButton(
//               onPressed: () => setState(() => _isSignup = !_isSignup),
//               child: Text(_isSignup ? 'Switch to Login' : 'Switch to Signup'),
//             ),
//             if (_isLoading) const CircularProgressIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Extension for capitalize
// extension StringExtension on String {
//   String get capitalize => "${this[0].toUpperCase()}${substring(1)}";
// }

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _role = 'passenger'; // Dropdown: passenger, driver
  bool _isSignup = false;
  bool _isLoading = false;

  Future<Map<String, double>?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    Position pos = await Geolocator.getCurrentPosition();
    return {'lat': pos.latitude, 'lng': pos.longitude};
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    try {
      final location = await _getCurrentLocation();
      if (_isSignup) {
        // Signup
        await _auth.createOrUpdateUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _role,
          location: location,
        );
        print('✅ Signup successful for ${_emailController.text.trim()} as $_role'); // Debug
      } else {
        // Login
        // FIXED: Only handle admin if email matches AND password matches hardcoded (or refactor)
        final enteredEmail = _emailController.text.trim();
        final enteredPassword = _passwordController.text.trim();
        if (_auth.isAdmin(enteredEmail) && enteredPassword == 'admin') {
          // Hardcoded admin - create if not exists
          await _auth.createOrUpdateUser(
            email: 'admin@example.com',
            password: 'admin',
            name: 'Admin',
            phone: '0000000000',
            role: 'admin',
            location: location,
          );
          print('✅ Admin created/updated'); // Debug
        }
        await _auth.login(enteredEmail, enteredPassword);
        print('✅ Login successful for $enteredEmail'); // Debug
      }
      // FIXED: Remove manual navigation – StreamBuilder in main.dart handles the UI switch automatically
      // No need for: Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      print('❌ Auth error: $e'); // Debug
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Signup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            if (_isSignup) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              DropdownButton<String>(
                value: _role,
                onChanged: (val) => setState(() => _role = val!),
                items: ['passenger', 'driver']
                    .map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(r.capitalize),
                ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleAuth,
              child: Text(_isSignup ? 'Signup' : 'Login'),
            ),
            TextButton(
              onPressed: () => setState(() => _isSignup = !_isSignup),
              child: Text(_isSignup ? 'Switch to Login' : 'Switch to Signup'),
            ),
            if (_isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// Extension for capitalize
extension StringExtension on String {
  String get capitalize => isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}"; // FIXED: Handle empty strings
}