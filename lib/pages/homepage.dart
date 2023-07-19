import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utility/router.dart' as route;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  final Set<Marker> _markers = {};
  Set<Marker> _previousMarkers = {};

  static final LatLngBounds _finlandBounds = LatLngBounds(
    southwest: const LatLng(59.5, 19.0),
    northeast: const LatLng(70.1, 32.0),
  );

  void _showCarWashDetails(dynamic carWashData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(carWashData['name']),
          content: Text(carWashData['formatted_address']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _getCurrentLocation({String? location}) async {
    if (location != null) {
      // Fetch car washes at the specified location
      _getCarWashes(location);
    } else {
      // Fetch car washes at the user's current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latitude = position.latitude;
      final longitude = position.longitude;

      final userLocation = '$latitude,$longitude';
      _getCarWashes(userLocation);
    }
  }

  void _getCarWashes(String location) async {
    const String baseUrl =
        'https://maps.googleapis.com/maps/api/place/textsearch/json';
    const String apiKey = 'AIzaSyA76Y-B6E49EVTQak85ygZuEKESUTTu_ts';
    List<String> query = [
      'car+washes+in+$location',
      'autopesula+in+$location',
      'autopesu+in+$location',
    ];
    final String url = '$baseUrl?query=$query&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      final results = decodedResponse['results'];

      setState(() {
        _previousMarkers = Set<Marker>.from(_markers);
        _markers.clear();
      });

      for (var result in results) {
        final location = result['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];

        Marker marker = Marker(
          markerId: MarkerId(result['place_id']),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: result['name'],
            snippet: result['formatted_address'],
            onTap: () {
              _showCarWashDetails(result);
            },
          ),
        );

        setState(() {
          _markers.add(marker);
        });
      }

      setState(() {
        _previousMarkers.clear();
      });
    } else {
      print('Error finding car wash locations: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    requestLocationPermission(); // Request location permission when the app is launched
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
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            minMaxZoomPreference: const MinMaxZoomPreference(5.0, 20.0),
            markers: _markers,
            // Add the bounds restriction to limit the map to Finland
            cameraTargetBounds: CameraTargetBounds(_finlandBounds),
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

    String? searchQuery = _searchController.text.trim();
    if (searchQuery.isNotEmpty) {
      _getCurrentLocation(location: searchQuery);
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> requestLocationPermission() async {
    PermissionStatus permissionStatus =
        await Permission.locationWhenInUse.request();

    if (permissionStatus.isGranted) {
      // Permission has been granted
      _getCurrentLocation(); // Automatically locate the user
    } else if (permissionStatus.isPermanentlyDenied) {
      // Permission has been permanently denied
      openAppSettings(); // Redirect to app settings to enable the permission manually
    }
  }

  void searchPlace(String query) async {
    if (query.trim().isEmpty || query == "null") {
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

        if (!_finlandBounds.contains(LatLng(lat, lng))) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Out of range (Limited area Finland)",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(lat, lng),
            12.0,
          ),
        );

        setState(() {
          _markers.clear(); // Clear the markers set
        });

        _getCarWashes(query); // Fetch car washes at the searched location

        setState(() {
          _previousMarkers.clear(); // Clear the previous markers set
        });
      }
    } catch (e) {
      if (e is NoResultFoundException) {
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
