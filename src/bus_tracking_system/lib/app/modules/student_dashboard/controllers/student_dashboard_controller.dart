import 'dart:developer';

import 'package:bus_tracking_system/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentDashboardController extends GetxController {
  //TODO: Implement StudentDashboardController

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getData();
    update();
  }

  List<String> locations = [
    'Orange Travels',
    'Intercity',
  ];

  List<String> drivers = [
    'Jhon',
    'Rajesh',
  ];

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
                Get.offAllNamed(Routes.LOGIN);
                // Perform logout operationGet
                // Add your logout logic here
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
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
        color: Colors.blue,
      ),
      backgroundColor: Colors.white,
      titleStyle: const TextStyle(
        color: Colors.blue,
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
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w900),
      ),
      onPressed: () {
        Get.back();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Yes",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w900)),
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

  Future<void> getData() async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('BusData');
    QuerySnapshot querySnapshot = await users.get();
    querySnapshot.docs.forEach((doc) {
      log('${doc.data()}'); // Use doc.data() to get the data of each document
    });
    update();
  }

  Future<void> updateData(int index, Map<String, dynamic> newData) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('BusData');
    QuerySnapshot querySnapshot = await users.get();
    if (index < querySnapshot.docs.length) {
      DocumentReference userDoc = querySnapshot.docs[index].reference;

      await userDoc.update(newData);
    } else {
      print('Index out of range');
    }
  }

  void addData() async {
    Map<String, dynamic> data = {
      'RouteNo': 'T-4',
      'College': 'SNSCT',
      'Route': [
        "Veerapandi Pirivu",
        "Jothipuram / Vannan Kovil",
        "Vadamadurai",
        "Thudiyalur",
        'Cheran colony',
        "Vellakinar",
        "Dr SNS Arts",
      ],
    };
    CollectionReference users =
        FirebaseFirestore.instance.collection('BusData');
    await users.add(data);
    print('Bus Data added successfully!');
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
  void increment() => count.value++;
}
