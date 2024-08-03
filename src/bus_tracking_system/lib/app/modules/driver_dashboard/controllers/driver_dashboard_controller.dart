import 'dart:async';
import 'dart:developer';

import 'package:bus_tracking_system/app/routes/app_pages.dart';
import 'package:bus_tracking_system/services/authServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverDashboardController extends GetxController {
  //TODO: Implement DriverDashboardController
  AuthService auth = AuthService();
  bool isStudent = true;
  SharedPreferences? pref;
  String routeName = "";
  String routeDocId = "";
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
  Timer? timer;

  final count = 0.obs;
  @override
  void onInit() async {
    super.onInit();
    pref = await SharedPreferences.getInstance();
    update();
    var temp = pref!.getString("email")!;
    update();
    routeName =
        temp.split("@").first.substring(0, 2).toUpperCase().split("").join("-");
    log(routeName);
    update();
    await findDocumentByFieldValue("BusData", "RouteNo", routeName);
    update();
  }

  void startTimer() {
    showDialog(
      barrierDismissible: false,
      context: Get.context!,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
          Get.back();
        });
        return Center(child: Lottie.asset('assets/images/done_anim.json'));
      },
    );
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      getCurrentLocation();
    });
  }

  Future<void> getCurrentLocation() async {
    isGettingLocation = true;
    update();

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
      update();
      log("Lat is ${lat.toString()}");
      log("Lng is ${lng.toString()}");
      users = FirebaseFirestore.instance.collection('BusData');
      updateLocation(lat!, lng!);
      distanceBetween = Geolocator.distanceBetween(
          11.103675898462944, 77.02643639434434, lat!, lng!);
      update();
      isGettingLocation = false;

      update();
      log(distanceBetween!.round().toString());
    }).catchError((e) {
      print(e);
    });
  }

  Future<void> findDocumentByFieldValue(
      String collectionPath, String fieldName, dynamic value) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .where(fieldName, isEqualTo: value)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.forEach((doc) {
          log('Document ID: ${doc.id}');
          routeDocId = doc.id;
        });
      } else {
        print('No documents found with $fieldName equal to $value');
      }
    } catch (e) {
      print('Error finding document: $e');
    }
  }

  Future<void> updateLocation(double lat, double lng) {
    // Call the user's CollectionReference to add a new user
    return users!
        .doc(routeDocId)
        .update({
          'lat': lat.toString(), // John Doe
          'lng': lng.toString(),
          'time': DateTime.now().toString()
        })
        .then((value) => print("Location Updated"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    timer!.cancel();
    update();
  }

  void logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    update();
    Get.defaultDialog(
      title: "Logging Out",
      barrierDismissible: false,
      content: const CircularProgressIndicator(
        strokeWidth: 4,
        strokeCap: StrokeCap.round,
        color: Colors.blueAccent,
      ),
      backgroundColor: Colors.white,
      titleStyle: const TextStyle(
        color: Colors.blueAccent,
      ),
      middleTextStyle: const TextStyle(color: Colors.white),
    );
    await pref.setBool("isLogin", false);
    Future.delayed(const Duration(milliseconds: 3000), () {
      Get.offAllNamed(Routes.LOGIN);
      update();
    });
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text(
        "Cancel",
        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900),
      ),
      onPressed: () {
        Get.back();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Yes",
          style:
              TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900)),
      onPressed: () {
        Get.back();
        logout();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Alert"),
      content: const Text("Sure you want to logout"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void increment() => count.value++;
}
