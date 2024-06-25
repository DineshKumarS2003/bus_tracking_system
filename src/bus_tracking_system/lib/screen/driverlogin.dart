import 'package:bus_tracking_system/screen/DriverDashboard.dart';
import 'package:bus_tracking_system/services/authServices.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bus_tracking_system/screen/locations_page.dart';
import 'package:bus_tracking_system/screen/DriverLoginPage.dart';
// import 'package:location/location.dart';

class DriverLogin extends StatefulWidget {
  //is a
  @override
  State<DriverLogin> createState() => _DriverLoginState();
}

class _DriverLoginState extends State<DriverLogin> {
  AuthService _auth = AuthService();
  bool isStudent = true;
  late final String email;
  late final String password;
  final _formfield = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool passToggle = true;

  late DatabaseReference dbRef;

  void toggleLoginOption() {
    setState(() {
      isStudent = !isStudent;
    });
  }

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('Students');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'BUS TRACKER',
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Form(
              key: _formfield,
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
                    isStudent ? 'LOGIN' : 'LOGIN',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    decoration: InputDecoration(
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
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: passController,
                    obscureText: passToggle,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              passToggle = !passToggle;
                            });
                          },
                          child: Icon(passToggle
                              ? Icons.visibility_off
                              : Icons.visibility)),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Password';
                      } else if (passController.text.length < 9) {
                        return "Password length should be more than 9 characters";
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Map<String, String> Students = {
                        'email': emailController.text,
                        'password': passController.text,
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) {
                          return DriverDashboard();
                        }),
                      );
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
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
                  SizedBox(height: 10),
                ],
              ))),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('password', password));
  }
}
