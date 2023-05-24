import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utility/router.dart' as route;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'
    show locationFromAddress, Location, NoResultFoundException;

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
  final TextEditingController _searchController = TextEditingController();
  late Box<double> _locationBox;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    requestLocationPermission(); // Request location permission when the app is launched
    openLocationBox(); // Open the Hive box for user location
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(16.0),
                              hintText: "Search for your localization",
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            onSubmitted: (value) {
                              searchPlace(value);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (showText) // Added condition to show the welcome text
                  Text(
                    'Welcome back, $email',
                    style: Theme.of(context).textTheme.headline6,
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
      _mapController = controller; // Assign the controller to _mapController
    });
  }

  Future<void> openLocationBox() async {
    await Hive.openBox<double>('userLocation');
    _locationBox = Hive.box<double>('userLocation');
  }

  Future<void> requestLocationPermission() async {
    PermissionStatus permissionStatus =
        await Permission.locationWhenInUse.request();

    if (permissionStatus.isGranted) {
      // Permission has been granted
      locateUser(); // Automatically locate the user
    } else if (permissionStatus.isPermanentlyDenied) {
      // Permission has been permanently denied
      openAppSettings(); // Redirect to app settings to enable the permission manually
    }
  }

  void locateUser() async {
    Position? position = await Geolocator.getCurrentPosition();

    if (position != null) {
      double lat = position.latitude;
      double lng = position.longitude;

      _locationBox.put('latitude', lat); // Save latitude to Hive
      _locationBox.put('longitude', lng); // Save longitude to Hive

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
            LatLng(lat, lng), 12.0), // Zoom in to the user's location
      );
    }
  }

  void searchPlace(String query) async {
    if (query.trim().isEmpty || query == "null") {
      // Display warning notification for empty or null search query
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "The requested location cannot be found or does not exist.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        Location firstResult = locations.first;
        double lat = firstResult.latitude;
        double lng = firstResult.longitude;

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(lat, lng),
            12.0,
          ),
        );
      }
    } catch (e) {
      if (e is NoResultFoundException) {
        // Display warning notification for non-existent location
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "The requested location cannot be found or does not exist.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
