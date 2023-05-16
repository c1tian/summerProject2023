import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utility/router.dart' as route;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? email;
  final _userInfo = Hive.box('userData');
  bool showText = true;
  GoogleMapController? _mapController;
  static const LatLng _center = LatLng(61.9241, 25.7482); // Center of Finland
  static const double _zoom = 6.0; // Initial zoom level

  @override
  void initState() {
    super.initState();
    email = FirebaseAuth.instance.currentUser?.email;
    print(FirebaseAuth.instance.currentUser?.email);
    showText = _userInfo.get('showText', defaultValue: true);
    if (showText) {
      startTimer();
    }
  }

  void startTimer() {
    Timer(const Duration(seconds: 15), () {
      setState(() {
        showText = false;
        _userInfo.put('showText', false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Where To Wash'),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey.shade800),
              child: const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/pfp_placeholder.jpg'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.directions_car_rounded),
              title: const Text('Car Washes'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded),
              title: const Text('Profile'),
              onTap: () => Navigator.pushNamed(context, route.profilePage),
            ),
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Settings'),
              onTap: () => Navigator.pushNamed(context, route.settingsPage),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: _zoom,
            ),
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            minMaxZoomPreference: const MinMaxZoomPreference(5.0, 20.0),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 34.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Card(
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(16.0),
                      hintText: "Search for your localization",
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                ),
                if (showText)
                  Text(
                    'Welcome back, $email',
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }
}
