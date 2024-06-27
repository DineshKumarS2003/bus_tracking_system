import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bus_tracking_system/screen/profile.dart';
import 'package:bus_tracking_system/screen/locations_page.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

class BusTracking extends StatefulWidget {
  @override
  _BusTrackingState createState() => _BusTrackingState();
}

//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Column(
//       children: [Text(latitude.toString())
//       , Text(longitude.toString())],
//     )); // Empty widget, no UI elements
//   }
// }

class _BusTrackingState extends State<BusTracking> {
  String apiKey =
      "AIzaSyCRF9Q1ttrleh04hqRlP_CqsFCPU815jJk"; //OpenRouteService API key
  late String distance = '';
  late String time = '';
  bool isLoading = false; //A flag to check the status of the api data loading
  late LatLng sourceLocation =
      const LatLng(11.100514313921465, 77.02668669630442); //For user location
  // late LatLng destinationLocation = LatLng(30.3253,
  //     78.0413); //Destination Location (retrieved from the firebase database; must be connected to firebase)
  late LatLng destinationLocation = const LatLng(0, 0);
  // double destinationLatitude = 0; // Initialize with default value
  // double destinationLongitude = 0; // Initialize with default value
  // List<LatLng> polylinePoints = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<Marker> markers = [];
  late DatabaseReference dbRef;
  var distanceBetween;
  List<LatLng> polylineCoordinates = [];
  PolylinePoints? polylinePoints;
  final Set<Polyline> polylines = {};
  // Query dbRef2 = FirebaseDatabase.instance.ref().child('DestinationLocation');

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints();

    markers.add(Marker(
      markerId: const MarkerId("marker1"),
      position: const LatLng(11.100514313921465, 77.02668669630442),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('College Location'),
            content: const Text("This is Your College's Location"),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    ));

    setState(() {});
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('DestinationLocation');
      getData(users);
    } catch (e) {
      throw Exception("Error accessing Firebase Database");
    }

    requestPermission();
  }

  Future<BitmapDescriptor> getResizedAssetIcon(String assetPath,
      {int width = 110}) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    ByteData? byteData =
        await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<void> getData(CollectionReference users) async {
    QuerySnapshot querySnapshot = await users.get();
    // querySnapshot.docs.forEach((doc) {
    //   log('${doc.data()}'); // Use doc.data() to get the data of each document
    // });
    final data = querySnapshot.docs[0];
    destinationLocation = LatLng(data['latitude'], data['longitude']);
    markers.add(Marker(
        markerId: MarkerId("busLocation"),
        position: destinationLocation,
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Bus Location'),
              content: const Text('Bus Current Location '),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
        // ignore: use_build_context_synchronously
        icon: await getResizedAssetIcon('assets/images/busicon.png')));
    log('Destination point is $destinationLocation');
    setState(() {});
  }

//Permission to access live-location
  Future<void> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
              'This app needs to access your location to work properly.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Settings'),
              onPressed: () => AppSettings.openAppSettings(),
            ),
          ],
        ),
      );
    } else if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
              'This app needs to access your location to work properly.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Settings'),
              onPressed: () => AppSettings.openAppSettings(),
            ),
          ],
        ),
      );
    } else {
      getCurrentLocation();
    }
  }

  //Extraction of Live-location
  Future<void> getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled == false) {
      await Geolocator.openLocationSettings();
    }
    log(serviceEnabled.toString());

    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).then((Position position) async {
      sourceLocation = LatLng(position.latitude, position.longitude);
      markers.add(Marker(
          markerId: MarkerId("sourceLocation"),
          position: sourceLocation,
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Your Location'),
                content: const Text('This is your current Location'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Ok'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(200)));
      log("Source Location is $sourceLocation");
      setState(() {});
      distanceBetween = Geolocator.distanceBetween(
          sourceLocation.latitude,
          sourceLocation.longitude,
          destinationLocation.latitude,
          destinationLocation.longitude);
      distance = (distanceBetween / 1000).toStringAsFixed(2);
      log('Distance Between Destination and Orgin is $distance');
      setState(() {});
      getPolyline(sourceLocation, destinationLocation);
      setState(() {});
    }).catchError((e) {
      print(e);
    });
  }

  //Time format
  String formatTime(double duration) {
    if (duration >= 60) {
      int hours = duration ~/ 60;
      int minutes = (duration % 60).toInt();
      return '${hours}h ${minutes}m';
    } else {
      return '${duration.round()}min';
    }
  }

  //Notification Alert for Bus_Arrival
  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        const DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'bus_arrival_channel',
      'Bus Arrival',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Bus is about to reach',
      'The bus will arrive within 2 minutes.',
      platformChannelSpecifics,
    );
  }

  //Calculate distance and time through an API request using OpenRouteService API
  Future<void> calculateDistanceAndTime() async {
    setState(() {
      isLoading = true;
    });

    String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${sourceLocation.longitude},${sourceLocation.latitude}&end=${destinationLocation.longitude},${destinationLocation.latitude}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final route = jsonResponse['features'][0]['properties'];
        setState(() {
          distance =
              (route['segments'][0]['distance'] / 1000).toStringAsFixed(2) +
                  "km";
          double duration = (route['segments'][0]['duration'] / 60);
          time = formatTime(duration);
        });
        //This will display an alert that the bus is near
        // if (double.parse(time) <= 2) {
        //   showNotification();
        // }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

/**** */
  void getPolyline(LatLng origin, LatLng destination) async {
    setState(() {});
    PolylineResult result = await polylinePoints!.getRouteBetweenCoordinates(
      apiKey,
      PointLatLng(origin.latitude, origin.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.status == 'OK') {
      result.points.forEach((PointLatLng point) {
        log(point.toString());
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        polylines.add(Polyline(
          polylineId: PolylineId('polyline_1'),
          color: Colors.red,
          width: 2,
          points: polylineCoordinates,
        ));
      });
    } else {
      print('Error: ${result.errorMessage}');
    }
  }

  //Fetching polylines points via the ORS API
  /* Future<List<LatLng>> fetchPolyline(LatLng source, LatLng destination) async {
    final response = await http.get(Uri.parse(
        'https://www.google.com/maps/dir/?api_key=$apiKey&start=${source.longitude},${source.latitude}&end=${destination.longitude},${destination.latitude}'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      log(jsonResponse);
      final coordinates =
          jsonResponse['features'][0]['geometry']['coordinates'];
      return coordinates
          .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
          .toList();
    } else {
      throw Exception('Failed to load polyline');
    }
  }*/

  static const CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(11.100514313921465, 77.02668669630442),
    zoom: 14.4746,
  );
  final Completer<GoogleMapController> controller =
      Completer<GoogleMapController>();

  CameraPosition kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Do you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                // Perform logout operation
                Navigator.of(context).pop();
                // Add your logout logic here
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDistanceTimeVisible = distance.isNotEmpty && time.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Select Route',
          style: TextStyle(color: Colors.black),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              color: Colors.black,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Select Route'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationsPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: _showLogoutConfirmationDialog,
            ),
          ],
        ),
      ),
      body: polylines.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Getting Your Location Please Wait.....'),
                  SizedBox(
                    height: 20,
                  ),
                  CircularProgressIndicator(
                    color: Colors.blue,
                  )
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    markers: markers.toSet(),
                    polylines: polylines,
                    initialCameraPosition: CameraPosition(
                      target: destinationLocation,
                      zoom: 10.7746,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      //controller;
                    },
                  ),
                  /* FlutterMap(
              options: MapOptions(
                center: LatLng(destinationLocation.latitude,
                    destinationLocation.longitude),
                zoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 30.0,
                      height: 30.0,
                      point: sourceLocation,
                      builder: (ctx) => Container(
                        child: Image.asset(
                          'assets/images/person.png', //Custom Person icon
                          width: 5.0,
                          height: 5.0,
                        ),
                      ),
                    ),
                    Marker(
                      width: 35.0,
                      height: 35.0,
                      point: LatLng(destinationLocation.latitude,
                          destinationLocation.longitude),
                      builder: (ctx) => Container(
                        child: Image.asset(
                          'assets/images/busicon.png', //Custom Bus icon
                          width: 5.0,
                          height: 5.0,
                        ),
                      ),
                    ),
                  ],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),*/
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Distance: $distance Km',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Latitude: ${destinationLocation.latitude}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Longitude: ${destinationLocation.longitude}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      // calculateDistanceAndTime();isLoading ? null : calculateDistanceAndTime,
                      /*  ElevatedButton(
                          onPressed: () {
                            isLoading
                                ? null
                                : calculateDistanceAndTime().then((value) {
                                    Map<String, String> values = {
                                      'Distance': distance,
                                      'Time': time,
                                      'sourceLocation':
                                          sourceLocation.toString(),
                                      'destinationLocation':
                                          destinationLocation.toString(),
                                    };
                                    dbRef.push().set(values);
                                  });
                          },
                          child: const Text('Show Distance & Time'),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors.grey;
                                }
                                return Colors
                                    .blue; //when ORS api data fetching is successful and it is ready to show required data(distance and time)
                              },
                            ),
                          ),
                        ),*/
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
