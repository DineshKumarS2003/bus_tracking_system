import 'dart:developer';

import 'package:bus_tracking_system/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  //TODO: Implement LoginController

  final count = 0.obs;
  FirebaseAuth? auth;
  bool isStudent = true;
  late final String email;
  late final String password;
  final formfield = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  SharedPreferences? pref;
  bool passToggle = true;

  void toggleLoginOption() {
    isStudent = !isStudent;
    update();
  }

  @override
  void onInit() async {
    super.onInit();
    auth = FirebaseAuth.instance;
    pref = await SharedPreferences.getInstance();

    update();
  }

  Future<void> signIn(String email, String password) async {
    Get.defaultDialog(
      title: "Logging In",
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
    ScaffoldMessenger.of(Get.context!)
        .showSnackBar(SnackBar(content: Text('Signed in as $email')));
    pref!.setBool("isLogin", true);
    pref!.setBool("isStudent", true);
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed(Routes.STUDENT_DASHBOARD);
    });

    update();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
  void increment() => count.value++;
}
