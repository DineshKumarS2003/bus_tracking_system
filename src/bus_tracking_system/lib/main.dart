import 'package:bus_tracking_system/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SharedPreferences pref = await SharedPreferences.getInstance();
  bool isLogin = pref.getBool("isLogin") ?? false;
  bool isStudentLoggedIn = pref.getBool("isStudent") ?? false;
  runApp(
    GetMaterialApp(
      title: "Application",
      debugShowCheckedModeBanner: false,
      initialRoute: isLogin
          ? isStudentLoggedIn
              ? Routes.STUDENT_DASHBOARD
              : Routes.DRIVER_DASHBOARD
          : AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
