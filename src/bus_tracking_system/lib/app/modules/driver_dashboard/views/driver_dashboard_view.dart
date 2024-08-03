import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/driver_dashboard_controller.dart';

class DriverDashboardView extends GetView<DriverDashboardController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverDashboardController>(builder: (ControllerCallback) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
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
            Text(
              'Bus Route : ${controller.routeName}',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () async {
                  controller.getCurrentLocation();
                  controller.startTimer();
                  controller.update();
                },
                child: const Text("Start Location Tracking")),
            const SizedBox(
              height: 10,
            ),
            controller.lat == null
                ? controller.isGettingLocation
                    ? const CircularProgressIndicator(
                        color: Colors.blueAccent,
                      )
                    : const Text(
                        'Click to Update Location',
                        style: TextStyle(color: Colors.blueAccent),
                      )
                : controller.isGettingLocation
                    ? const CircularProgressIndicator(
                        color: Colors.blueAccent,
                      )
                    : const Text(
                        'Location Updated Successfully!',
                        style: TextStyle(color: Colors.green),
                      ),
            const SizedBox(
              height: 100,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 130, left: 130),
              child: ElevatedButton(
                onPressed: () async {
                  controller.showAlertDialog(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Logout"),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.logout),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        )),
      );
    });
  }
}
