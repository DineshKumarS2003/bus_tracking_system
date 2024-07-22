import 'package:get/get.dart';

import 'package:bus_tracking_system/app/modules/driver_dashboard/bindings/driver_dashboard_binding.dart';
import 'package:bus_tracking_system/app/modules/driver_dashboard/views/driver_dashboard_view.dart';
import 'package:bus_tracking_system/app/modules/driver_login/bindings/driver_login_binding.dart';
import 'package:bus_tracking_system/app/modules/driver_login/views/driver_login_view.dart';
import 'package:bus_tracking_system/app/modules/home/bindings/home_binding.dart';
import 'package:bus_tracking_system/app/modules/home/views/home_view.dart';
import 'package:bus_tracking_system/app/modules/login/bindings/login_binding.dart';
import 'package:bus_tracking_system/app/modules/login/views/login_view.dart';
import 'package:bus_tracking_system/app/modules/profile/bindings/profile_binding.dart';
import 'package:bus_tracking_system/app/modules/profile/views/profile_view.dart';
import 'package:bus_tracking_system/app/modules/splash/bindings/splash_binding.dart';
import 'package:bus_tracking_system/app/modules/splash/views/splash_view.dart';
import 'package:bus_tracking_system/app/modules/student_dashboard/bindings/student_dashboard_binding.dart';
import 'package:bus_tracking_system/app/modules/student_dashboard/views/student_dashboard_view.dart';
import 'package:bus_tracking_system/app/modules/tracking_screen/bindings/tracking_screen_binding.dart';
import 'package:bus_tracking_system/app/modules/tracking_screen/views/tracking_screen_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
        name: _Paths.LOGIN,
        page: () => LoginView(),
        binding: LoginBinding(),
        transition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 200)),
    GetPage(
        name: _Paths.DRIVER_LOGIN,
        page: () => DriverLoginView(),
        binding: DriverLoginBinding(),
        transition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 200)),
    GetPage(
        name: _Paths.STUDENT_DASHBOARD,
        page: () => StudentDashboardView(),
        binding: StudentDashboardBinding(),
        transition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 200)),
    GetPage(
        name: _Paths.TRACKING_SCREEN,
        page: () => TrackingScreenView(),
        binding: TrackingScreenBinding(),
        transition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 200)),
    GetPage(
        name: _Paths.DRIVER_DASHBOARD,
        page: () => DriverDashboardView(),
        binding: DriverDashboardBinding(),
        transition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 200)),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}
