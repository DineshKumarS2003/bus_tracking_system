import 'dart:developer';

import 'package:bus_tracking_system/app/modules/driver_dashboard/controllers/driver_dashboard_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class GetCurrentLocation {
  Position? currentPosition;
  LocationPermission? permission;
  double? distanceBetween;
  double? lat;
  double? lng;
  bool isGettingLocation = false;
  CollectionReference? users;
  DriverDashboardController con = Get.find<DriverDashboardController>();
  Future<LatLng> getCurrentLocation() async {
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
      log("Lat is ${lat.toString()}");
      log("Lng is ${lng.toString()}");
      updateLocation(lat!, lng!);
      distanceBetween = Geolocator.distanceBetween(
          11.103675898462944, 77.02643639434434, lat!, lng!);
      print(Geolocator.distanceBetween(11.414595996555862, 79.00924599565325,
          11.103759287213032, 77.02723365992713));
      con.distanceBetween = distanceBetween;
      con.update();
      isGettingLocation = false;
      log(distanceBetween!.round().toString());
      return LatLng(currentPosition!.latitude, currentPosition!.longitude);
    }).catchError((e) {
      print(e);
    });
    return LatLng(currentPosition!.latitude, currentPosition!.longitude);
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
