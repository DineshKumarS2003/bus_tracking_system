import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_settings/app_settings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:ui' as ui;

class TrackingScreenController extends GetxController {
  String busLat = Get.arguments["lat"];
  String busLng = Get.arguments["lng"];
  int index = Get.arguments["index"];
  int count = 0;
  String apiKey =
      "AIzaSyCRF9Q1ttrleh04hqRlP_CqsFCPU815jJk"; //OpenRouteService API key
  late String distance = '';
  String travelTime = '';
  late String time = '';
  bool isLoading = false; //A flag to check the status of the api data loading
  late LatLng sourceLocation = const LatLng(0, 0);
  late LatLng destinationLocation = const LatLng(0, 0);
  List<Marker> markers = [];
  List<LatLng> polylineCoordinates = [];
  PolylinePoints? polylinePoints;
  var distanceBetween;
  final Set<Polyline> polylines = {};
  late GoogleMapController mapController;
  final LatLng initialPosition =
      const LatLng(37.77483, -122.41942); // Initial position (San Francisco)
  Marker? marker;
  BitmapDescriptor? busIcon;
  Timer? timer;
  Stopwatch? stopwatch1;

  @override
  void onInit() async {
    super.onInit();
    polylinePoints = PolylinePoints();
    listenToBusLocation(index);
    loadBusIcon();
    markers.add(Marker(
      markerId: const MarkerId("marker1"),
      position: const LatLng(11.100514313921465, 77.02668669630442),
      onTap: () {
        showDialog(
          context: Get.context!,
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
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('BusData');
      getData(users, index);
    } catch (e) {
      throw Exception("Error accessing Firebase Database");
    }

    requestPermission();
  }

  Future<void> loadBusIcon() async {
    final Uint8List busIconBytes =
        await loadAndResizeAsset('assets/images/busicon.png', 100, 100);
    final icon = BitmapDescriptor.fromBytes(busIconBytes);

    busIcon = icon;
    update();
  }

  Future<Uint8List> loadAndResizeAsset(
      String path, int width, int height) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes,
        targetWidth: width, targetHeight: height);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image resizedImage = frameInfo.image;

    final ByteData? byteData =
        await resizedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> getData(CollectionReference users, int index) async {
    QuerySnapshot querySnapshot = await users.get();
    // querySnapshot.docs.forEach((doc) {
    //   log('${doc.data()}'); // Use doc.data() to get the data of each document
    // });
    final data = querySnapshot.docs[index];
    log("Document Id of by the Index is ${querySnapshot.docs[index].id}");
    sourceLocation =
        LatLng(double.parse(data['lat']), double.parse(data['lng']));
    update();
    markers.add(Marker(
        markerId: const MarkerId("busLocation"),
        position: sourceLocation,
        onTap: () {
          showDialog(
            context: Get.context!,
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
        icon: busIcon!));
    log('Source point is $sourceLocation');
    update();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      count++;
      if (count > 12) {
        showDialog(
          context: Get.context!,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Alert'),
            content: const Text('Bus is waiting more than a Minute'),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
        count = 0;
        timer.cancel();
        update();
      }
      log("The Count of the value is $count");
    });
  }

  /* Future<void> checkLocation() async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('DestinationLocation');
    getData(users);
    QuerySnapshot querySnapshot = await users.get();
    // querySnapshot.docs.forEach((doc) {
    //   log('${doc.data()}'); // Use doc.data() to get the data of each document
    // });
    final data = querySnapshot.docs[0];
    LatLng tempLocation = sourceLocation;
    sourceLocation = LatLng(data['latitude'], data['longitude']);
    update();
    if (tempLocation.latitude.toString().substring(0, 7) ==
            sourceLocation.latitude.toString().substring(0, 7) &&
        tempLocation.longitude.toString().substring(0, 7) ==
            sourceLocation.longitude.toString().substring(0, 7)) {
      count++;
      if (count > 12) {
        showDialog(
          context: Get.context!,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Alert'),
            content: const Text('Bus is waiting more than a Minute'),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
    log('Destination point is $sourceLocation');
    update();
  }*/

  Future<String?> getDocumentIdByIndex(String collectionPath, int index) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(collectionPath).get();

    if (index < querySnapshot.docs.length) {
      return querySnapshot.docs[index].id;
    } else {
      return null;
    }
  }

  Future<void> listenToBusLocation(int index) async {
    String? documentId = await getDocumentIdByIndex("BusData", index);
    FirebaseFirestore.instance
        .collection('BusData')
        .doc('$documentId')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        update();
        final data = snapshot.data();
        if (data != null) {
          final lat = double.parse(data['lat']);
          final lng = double.parse(data['lng']);
          log("Listening to Data in Firebase");
          log("lat is $lat and lng is $lng");

          final newPosition = LatLng(lat, lng);
          updateMarker(newPosition);
          update();
        }
      }
    });
  }

  void updateMarker(LatLng newPosition) {
    mapController.animateCamera(
      CameraUpdate.newLatLng(newPosition),
    );
    sourceLocation = newPosition;
    update();
    marker = Marker(
      markerId: const MarkerId('busLocation'),
      position: newPosition,
      icon: busIcon!,
      infoWindow: const InfoWindow(title: 'Bus Location'),
    );
    markers.add(marker!);
    polylineCoordinates.clear();
    getPolyline(sourceLocation, destinationLocation);
    update();
    distanceBetween = Geolocator.distanceBetween(
        sourceLocation.latitude,
        sourceLocation.longitude,
        destinationLocation.latitude,
        destinationLocation.longitude);
    update();
    //? (distanceBetween / 500) Here 500 is the average speed(50 Km/hr + 0)
    travelTime = "${(distanceBetween / 500).toStringAsFixed(2)}";
    log('Time to travel is $travelTime');
    distance = (distanceBetween / 1000).toStringAsFixed(2);
    log('Distance Between Destination and Orgin is $distance');
    update();
  }

//Permission to access live-location
  Future<void> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    update();
    if (permission == LocationPermission.denied) {
      showDialog(
        context: Get.context!,
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
        context: Get.context!,
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
    update();
    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).then((Position position) async {
      destinationLocation = LatLng(position.latitude, position.longitude);
      markers.add(Marker(
          markerId: const MarkerId("sourceLocation"),
          position: destinationLocation,
          onTap: () {
            showDialog(
              context: Get.context!,
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
      log("Destination is $destinationLocation");
      update();
      distanceBetween = Geolocator.distanceBetween(
          sourceLocation.latitude,
          sourceLocation.longitude,
          destinationLocation.latitude,
          destinationLocation.longitude);
      update();
      distance = (distanceBetween / 1000).toStringAsFixed(2);
      travelTime = "${(distanceBetween / 500).toStringAsFixed(2)}";
      log('Time to travel is $travelTime');
      log('Distance Between Destination and Orgin is $distance');
      getPolyline(sourceLocation, destinationLocation);
      update();
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
  }

  //Calculate distance and time through an API request using OpenRouteService API
  /* Future<void> calculateDistanceAndTime() async {
    isLoading = true;
    update();

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
  }*/

/**** */
  void getPolyline(LatLng origin, LatLng destination) async {
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

      polylines.add(Polyline(
        polylineId: const PolylineId('polyline_1'),
        color: Colors.red,
        width: 2,
        points: polylineCoordinates,
      ));
      update();
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

  CameraPosition kLake = const CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  void showLogoutConfirmationDialog() {
    showDialog(
      context: Get.context!,
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
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
}
