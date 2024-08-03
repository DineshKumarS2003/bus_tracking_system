import 'dart:developer';

import 'package:bus_tracking_system/app/Models/BusModel.dart';
import 'package:bus_tracking_system/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/student_dashboard_controller.dart';

class StudentDashboardView extends GetView<StudentDashboardController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<StudentDashboardController>(builder: (controller) {
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
                  color: Colors.blueAccent,
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
                title: const Row(
                  children: [
                    Text('Logout'),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.logout)
                  ],
                ),
                onTap: () {
                  Get.back();
                  controller.showAlertDialog(context);
                },
              ),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('BusData').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            List<BusData> busDataList = snapshot.data!.docs
                .map((doc) => BusData.fromFirestore(doc))
                .toList();

            return ListView.builder(
              itemCount: busDataList.length,
              itemBuilder: (context, index) {
                BusData busData = busDataList[index];
                return GestureDetector(
                    onTap: () {
                      log(index.toString());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(255, 161, 160, 160),
                                spreadRadius: 2,
                                blurRadius: 5,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bus Route No: ${busData.routeNo}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              // Text(
                              //   busData.college,
                              //   style: const TextStyle(
                              //     fontWeight: FontWeight.normal,
                              //     fontSize: 12,
                              //   ),
                              // ),

                              Row(
                                children: [
                                  Text(
                                    busData.route[0],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  const Text(
                                    "⇆",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    busData.college,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  log("$index");
                                  Get.toNamed(Routes.TRACKING_SCREEN,
                                      arguments: {
                                        "lat": busData.lat,
                                        "lng": busData.lng,
                                        "index": index
                                      });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Track Bus',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));
              },
            );
          },
        ),

        /*ListView.builder(
          itemCount: controller.locations.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(255, 161, 160, 160),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.locations[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Driver: ${controller.drivers[index]}',
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Get.toNamed(Routes.TRACKING_SCREEN);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Track Bus',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),*/
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     controller.addData();
        //   },
        //   isExtended: true,
        //   backgroundColor: Colors.blueAccent,
        //   child: const Text(
        //     'ADD',
        //     style: TextStyle(color: Colors.white),
        //   ),
        // ),
      );
    });
  }
}
