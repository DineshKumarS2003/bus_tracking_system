import 'dart:developer';
import 'package:bus_tracking_system/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverLoginController extends GetxController {
  final count = 0.obs;
  FirebaseAuth? auth;
  bool isStudent = true;
  late final String email;
  late final String password;
  final formfield = GlobalKey<FormState>();
  SharedPreferences? pref;
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool passToggle = true;

  @override
  void onInit() async {
    super.onInit();
    auth = FirebaseAuth.instance;
    pref = await SharedPreferences.getInstance();
    update();
  }

  void toggleLoginOption() {
    isStudent = !isStudent;
    update();
  }

  Future<void> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      pref!.setString("email", email);
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
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          content: Text('Signed in as ${userCredential.user?.email}')));
      pref!.setBool("isLogin", true);
      pref!.setBool("isStudent", false);
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed(Routes.DRIVER_DASHBOARD);
      });

      update();
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(content: Text("Invalid Login Credentials")));
      update();
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
  void increment() => count.value++;
}
