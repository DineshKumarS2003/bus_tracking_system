import 'package:bus_tracking_system/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.blue,
          title: const Text(
            'BUS TRACKER',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Form(
                key: controller.formfield,
                child: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/student_icon.png",
                      height: 100,
                      width: 100,
                    ),
                    Text(
                      controller.isStudent ? 'LOGIN' : 'LOGIN',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: controller.emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        bool emailValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value!);

                        if (value.isEmpty) {
                          return "Enter Email";
                        } else if (!emailValid) {
                          return "Enter valid Email";
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: controller.passwordController,
                      obscureText: controller.passToggle,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: InkWell(
                            onTap: () {
                              controller.passToggle = !controller.passToggle;
                              controller.update();
                            },
                            child: Icon(controller.passToggle
                                ? Icons.visibility_off
                                : Icons.visibility)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        controller.signIn(controller.emailController.text,
                            controller.passwordController.text);
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        if (controller.isStudent) {
                          Get.toNamed(Routes.DRIVER_LOGIN);
                        } else {
                          Get.offAllNamed(Routes.STUDENT_DASHBOARD);
                        }
                      },
                      child: Text(
                        controller.isStudent
                            ? 'Log in as Bus'
                            : 'Log in as Student',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ))),
          ),
        ),
      );
    });
  }
}
