import 'dart:developer';

import 'package:bus_tracking_system/services/authServices.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:location/location.dart';

class DriverDashboard extends StatefulWidget {
  //is a
  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  AuthService auth = AuthService();
  bool isStudent = true;
  late final String email;
  late final String password;
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool passToggle = true;
  LatLng? sourceLocation;
  Position? currentPosition;
  LocationPermission? permission;
  double? distanceBetween;
  double? lat;
  double? lng;
  bool isGettingLocation = false;
  CollectionReference? users;

  late DatabaseReference dbRef;

  void toggleLoginOption() {
    setState(() {
      isStudent = !isStudent;
    });
  }

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('Students');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'BUS TRACKER',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
          child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Image.asset(
            "assets/images/driver icon.png",
            height: 100,
            width: 100,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Driver Name : Rajesh',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Bus Name : Intercity 1',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () async {
                await getCurrentLocation();
                setState(() {});
              },
              child: const Text("Update Location")),
          const SizedBox(
            height: 10,
          ),
          lat == null
              ? isGettingLocation
                  ? const CircularProgressIndicator(
                      color: Colors.blue,
                    )
                  : const Text(
                      'Click to Update Location',
                      style: TextStyle(color: Colors.blue),
                    )
              : isGettingLocation
                  ? const CircularProgressIndicator(
                      color: Colors.blue,
                    )
                  : const Text(
                      'Location Updated Successfully!',
                      style: TextStyle(color: Colors.green),
                    )
        ],
      )),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('password', password));
  }

  // Future<void> getCurrentLocation() async {
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   setState(() {
  //     sourceLocation = LatLng(position.latitude, position.longitude);
  //     print(sourceLocation);
  //   });
  // }

  Future<void> getCurrentLocation() async {
    isGettingLocation = true;
    setState(() {});

    permission = await Geolocator.requestPermission();
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
      currentPosition = position;
      lat = currentPosition!.latitude;
      lng = currentPosition!.longitude;
      setState(() {});
      log("Lat is ${lat.toString()}");
      log("Lng is ${lng.toString()}");
      users = FirebaseFirestore.instance.collection('DestinationLocation');
      setState(() {});
      updateLocation(lat!, lng!);
      distanceBetween = Geolocator.distanceBetween(
          11.103675898462944, 77.02643639434434, lat!, lng!);
      print(Geolocator.distanceBetween(11.414595996555862, 79.00924599565325,
          11.103759287213032, 77.02723365992713));
      isGettingLocation = false;
      setState(() {});
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pop(true);
          });
          return Center(child: Lottie.asset('assets/images/done_anim.json'));
        },
      );
      setState(() {});
      log(distanceBetween!.round().toString());
      setState(() {});
    }).catchError((e) {
      print(e);
    });
  }

  Future<void> updateLocation(double lat, double lng) {
    // Call the user's CollectionReference to add a new user
    return users!
        .doc('A40qQsVZD4XHWzhJVSQM')
        .update({
          'latitude': lat, // John Doe
          'longitude': lng,
        })
        .then((value) => print("Location Updated"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}
