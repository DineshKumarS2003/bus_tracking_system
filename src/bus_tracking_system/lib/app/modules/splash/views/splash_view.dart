import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (controller) {
      return Scaffold(
        body: Center(
          child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(color: Color(0xfff6f8f4)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/bus.png',
                    ),
                  ),
                  Text(
                    "BUS TARCKER",
                    style: TextStyle(
                      height: 5,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 30.0,
                    ),
                  ),
                  CircularProgressIndicator(),
                ],
              )),
        ),
      );
    });
  }
}
