import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/app_drawer.dart';

class NearbyUsersScreen extends StatefulWidget {
  const NearbyUsersScreen({super.key});

  @override
  State<NearbyUsersScreen> createState() => _NearbyUsersScreenState();
}

class _NearbyUsersScreenState extends State<NearbyUsersScreen>
    with TickerProviderStateMixin {
  Position? _currentPosition;
  String? _myRole;
  bool _mapReady = false;

  final MapController _mapController = MapController();

  Timer? _locationTimer;

  /// Smooth animated positions for other users
  final Map<String, LatLng> _otherUsers = {};

  /// Track tickers so we can dispose them later
  final List<AnimationController> _activeControllers = [];

  @override
  void initState() {
    super.initState();
    _initLocationAndRole();

    // Update own location every 5 seconds
    _locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _updateMyLocation(),
    );
  }

  @override
  void dispose() {
    _locationTimer?.cancel();

    // Dispose all animation controllers
    for (final c in _activeControllers) {
      c.dispose();
    }

    super.dispose();
  }

  //Live updating of own location
  Future<void> _updateMyLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'location': GeoPoint(pos.latitude, pos.longitude),
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() => _currentPosition = pos);

      if (_mapReady) {
        _mapController.move(LatLng(pos.latitude, pos.longitude), 14);
      }
    } catch (e) {
      debugPrint("Live location update error: $e");
    }
  }

  //Initial setup: permissions, location, role
  Future<void> _initLocationAndRole() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        return;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = userDoc.data()?['role'];

      // Save my initial position
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'location': GeoPoint(pos.latitude, pos.longitude),
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        _currentPosition = pos;
        _myRole = role;
      });

      if (_mapReady) {
        _mapController.move(LatLng(pos.latitude, pos.longitude), 14);
      }
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  //Stream: only show the opposite role (resident ↔ professional)
  Stream<QuerySnapshot<Map<String, dynamic>>> _nearbyUsersStream() {
    if (_myRole == null) return const Stream.empty();

    final targetRole = _myRole == 'resident' ? 'professional' : 'resident';

    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: targetRole)
        .where('location', isNotEqualTo: null)
        .snapshots();
  }

  String _formatDistance(LatLng a, LatLng b) {
    final meters = Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );

    if (meters < 1000) {
      return "${meters.toStringAsFixed(0)} m";
    } else {
      return "${(meters / 1000).toStringAsFixed(2)} km";
    }
  }

  // UI + smoothed marker animation
  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null || _myRole == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _myRole == 'resident'
              ? "Available Professionals"
              : "Available Residents",
        ),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _nearbyUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            for (final doc in snapshot.data!.docs) {
              final data = doc.data();
              final geo = data['location'];
              if (geo is! GeoPoint) continue;

              final newPos = LatLng(geo.latitude, geo.longitude);

              // If user is already tracked, animate movement
              if (_otherUsers.containsKey(doc.id)) {
                final oldPos = _otherUsers[doc.id]!;

                // FIX: If no movement → do NOT animate
                if (oldPos.latitude == newPos.latitude &&
                    oldPos.longitude == newPos.longitude) {
                  continue;
                }

                // Smooth animation
                final controller = AnimationController(
                  vsync: this,
                  duration: const Duration(milliseconds: 800),
                );

                final tween = Tween<LatLng>(begin: oldPos, end: newPos);

                controller.addListener(() {
                  setState(() {
                    _otherUsers[doc.id] = tween.evaluate(controller);
                  });
                });

                controller.addStatusListener((status) {
                  if (status == AnimationStatus.completed) {
                    controller.dispose();
                  }
                });

                _activeControllers.add(controller);
                controller.forward();
              } else {
                // First time: set instantly
                _otherUsers[doc.id] = newPos;
              }
            }
          }

          // Build markers
          final markers = <Marker>[
            // Me
            Marker(
              width: 40,
              height: 40,
              point: LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              child: const Icon(
                Icons.my_location,
                size: 40,
                color: Colors.blue,
              ),
            ),
          ];

          // Other users
          _otherUsers.forEach((id, pos) {
            final distanceText = _formatDistance(
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              pos,
            );

            markers.add(
              Marker(
                width: 80,
                height: 80,
                point: pos,
                child: Column(
                  children: [
                    const Icon(Icons.location_pin, size: 40, color: Colors.red),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        distanceText,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialZoom: 14,
              initialCenter: LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              onMapReady: () {
                setState(() => _mapReady = true);
                _mapController.move(
                  LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  14,
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'your.app.id',
              ),
              MarkerLayer(key: ValueKey(_otherUsers.length), markers: markers),
            ],
          );
        },
      ),
    );
  }
}
