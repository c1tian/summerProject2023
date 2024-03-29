import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utility/router.dart' as route;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  int counterValue = 0; // Counter value that can be updated later
  String? email;
  final _userInfo = Hive.box('userData');
  bool showText = true;
  GoogleMapController? _mapController;
  LatLng _getLocation = const LatLng(61.5526, 25.4453); // Center of Finland
  final TextEditingController _searchController = TextEditingController();
  final Set<Marker> _markers = {};
  Set<Marker> _previousMarkers = {};

  static final LatLngBounds _finlandBounds = LatLngBounds(
    southwest: const LatLng(59.5, 19.0),
    northeast: const LatLng(70.1, 32.0),
  );

  // Method to increment the counter value and update it in to Firestore
  void _incrementCounterValue() async {
    setState(() {
      counterValue++;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('Users').doc(user.uid);
      await userDocRef.update({'points': counterValue});
    }
  }

  // Method to update user points in to Firestore
  void _updatePoints(int newPoints) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('Users').doc(user.uid);
      await userDocRef.update({'points': newPoints});
    }
  }

  // Method to save car wash details to Firestore
  void saveCarWashes(
    String name,
    String details,
    String openHours,
    String prices,
    String discounts,
  ) async {
    // Separate the prices and discounts with commas
    String formattedHours = openHours.split('\n').join(',');
    String formattedPrices = prices.split('\n').join(',');
    String formattedDiscounts = discounts.split('\n').join(',');

    try {
      // Check if the car wash data already exists for the user
      final carWashDocRef =
          FirebaseFirestore.instance.collection('CarWashes').doc(name);

      if (await carWashDocRef.get().then((doc) => doc.exists)) {
        // Car wash data already exists, update the document only if the values are not null
        Map<String, dynamic> updateData = {};
        if (details.isNotEmpty) updateData['Details'] = details;
        if (formattedHours.isNotEmpty) updateData['OpenHours'] = formattedHours;
        if (formattedPrices.isNotEmpty) updateData['Prices'] = formattedPrices;
        if (formattedDiscounts.isNotEmpty) {
          updateData['Discounts'] = formattedDiscounts;
        }

        if (updateData.isNotEmpty) {
          await carWashDocRef.update(updateData);
          print('Car wash data has updated.');
        } else {
          print('No new data has updated.');
        }
      } else {
        // If car wash data does not exist, add a new document
        await carWashDocRef.set({
          'Name': name,
          'Details': details,
          'OpenHours': openHours,
          'Prices': formattedPrices,
          'Discounts': formattedDiscounts,
        });
        print('New car wash data has added.');
      }
    } catch (e) {
      print('Error saving car wash data: $e');
    }
  }

  // Method to display car wash details in a dialog
  void _showCarWashDetails(dynamic carWashData) async {
    final carWashDocRef = FirebaseFirestore.instance
        .collection('CarWashes')
        .doc(carWashData['name']);
    final carWashSnapshot = await carWashDocRef.get();
    final carWashFirestoreData = carWashSnapshot.data();

    TextEditingController openHoursController = TextEditingController();
    TextEditingController pricesController = TextEditingController();
    TextEditingController discountsController = TextEditingController();

    pricesController.text = carWashFirestoreData?['Prices'] ?? '';
    discountsController.text = carWashFirestoreData?['Discounts'] ?? '';
    openHoursController.text = carWashFirestoreData?['OpenHours'] ?? '';

    openHoursController.text =
        carWashFirestoreData?['OpenHours']?.replaceAll(',', '\n') ?? '';
    pricesController.text =
        carWashFirestoreData?['Prices']?.replaceAll(',', '\n') ?? '';
    discountsController.text =
        carWashFirestoreData?['Discounts']?.replaceAll(',', '\n') ?? '';

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(carWashData['name']),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(carWashData['formatted_address']),
                    const SizedBox(height: 18),
                    const Text(
                      'Opening hours:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: openHoursController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText:
                            'Enter opening hours here. Example:\nMA-PE 7-20\nLA-SU 10-18',
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Prices:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: pricesController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Enter prices here. Example:\nHarjapesu 15e',
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Discounts:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: discountsController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText:
                            'Enter discounts here. Example:\nDiscount A -5%',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () async {
                    // Save car wash data to Firestore
                    saveCarWashes(
                      carWashData['name'],
                      carWashData['formatted_address'],
                      openHoursController.text,
                      pricesController.text,
                      discountsController.text,
                    );
                    _incrementCounterValue(); // Increment the counter when data is updated
                    _updatePoints(counterValue);

                    // Show a success message to the user (you can customize this part)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Car wash data saved.'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method to get the user's current location
  void _getCurrentLocation({String? location}) async {
    if (location != null) {
      // Fetch car washes at the specified location
      _getCarWashes(location);
    } else {
      // Fetch car washes at the user's current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _getLocation = LatLng(position.latitude, position.longitude);

      final latitude = position.latitude;
      final longitude = position.longitude;

      CameraPosition cameraPosition =
          CameraPosition(target: _getLocation, zoom: 11);
      _mapController
          ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      final userLocation = '$latitude,$longitude';
      _getCarWashes(userLocation);
    }
  }

  // Method to get car wash data from Google Places API
  void _getCarWashes(
    String location,
  ) async {
    const String baseUrl =
        'https://maps.googleapis.com/maps/api/place/textsearch/json';
    const String apiKey =
        'YOUR API KEY HERE!!!'; // Replace text with your API key
    List<String> query = [
      'car+washes+in+$location',
      'autopesula+in+$location',
      'autopesu+in+$location',
    ];
    final String url = '$baseUrl?query=$query&key=$apiKey&location=$location';

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
          onTap: () {
            _showCarWashDetails(result);
            // Save car wash data to Firestore automatically when the marker is tapped
            saveCarWashes(
              result['name'],
              result['formatted_address'],
              '',
              '',
              '',
            );
          },
          markerId: MarkerId(result['place_id']),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
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

  // Method to fetch and set the counter value from Firestore
  void _fetchCounterValue() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('Users').doc(user.uid);
      final userSnapshot = await userDocRef.get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data(); // Get the document data as a map
        if (userData != null && userData.containsKey('points')) {
          setState(() {
            counterValue = userData['points'];
          });
        } else {
          // If the 'points' field does not exist or is null, set the counterValue to 0
          setState(() {
            counterValue = 0;
          });
        }
      }
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
    _fetchCounterValue();
    requestLocationPermission(); // Request location permission when the app is launched
    email = FirebaseAuth.instance.currentUser?.email;
    print(FirebaseAuth.instance.currentUser?.email);
    showText = _userInfo.get('showText', defaultValue: true);
    if (showText) {
      startTimer();
    }
    _getCurrentLocation();
  }

  // Method to start a timer for showing a welcome message
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
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopify, size: 30),
              ),
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: Text(
                    counterValue.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
            initialCameraPosition: CameraPosition(
              target: _getLocation,
              zoom: 11,
            ),
            myLocationEnabled: true,
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
                if (showText)
                  Text(
                    'Welcome back, $email',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to handle the creation of GoogleMap widget
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

  // Method to request location permission
  Future<void> requestLocationPermission() async {
    PermissionStatus permissionStatus =
        await Permission.locationWhenInUse.request();

    if (permissionStatus.isGranted) {
      _getCurrentLocation();
    } else if (permissionStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  // Method to search for a place using geocoding
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
            11.0,
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
