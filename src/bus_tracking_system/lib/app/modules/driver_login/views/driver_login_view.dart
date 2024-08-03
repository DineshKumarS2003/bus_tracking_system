import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/driver_login_controller.dart';

class DriverLoginView extends GetView<DriverLoginController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverLoginController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'BUS TRACKER',
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
                      "assets/images/driver icon.png",
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: controller.passController,
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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Password';
                        } else if (controller.passController.text.length < 9) {
                          return "Password length should be more than 9 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        controller.signIn(controller.emailController.text,
                            controller.passController.text);
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
                  ],
                ))),
          ),
        ),
      );
    });
  }
}
