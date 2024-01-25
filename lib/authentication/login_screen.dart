import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:kp_driver/Widgets/loading_dialog.dart';
import 'package:kp_driver/authentication/signup_screen.dart';
import 'package:kp_driver/global/global_var.dart';
import 'package:kp_driver/methods/common_methods.dart';
import 'package:kp_driver/pages/dashboard.dart';

class LoiginScreen extends StatefulWidget {
  const LoiginScreen({super.key});

  @override
  State<LoiginScreen> createState() => _LoiginScreenState();
}

class _LoiginScreenState extends State<LoiginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);
    loginFormValidation();
  }

  loginFormValidation() {
    if (!emailTextEditingController.text.contains('@')) {
      cMethods.displaySnackBar("provide a valid email", context);
    } else if (passwordTextEditingController.text.trim().length < 5) {
      cMethods.displaySnackBar("passwor must be atleast 6 characters", context);
    } else {
      signInUser();
    }
  }

  signInUser() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "signing in..."));

    final User? userFirebase = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailTextEditingController.text.trim(),
                password: passwordTextEditingController.text.trim())
            .catchError((errormsg) {
      Navigator.pop(context);
      cMethods.displaySnackBar(errormsg.toString(), context);
    }))
        .user;
    if (!context.mounted) return;
    Navigator.pop(context);

    if (userFirebase != null) {
      DatabaseReference usersRef = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(userFirebase.uid);
      usersRef.once().then((snap) {
        if (snap.snapshot.value != null) {
          if ((snap.snapshot.value as Map)["blockstatus"] == "no") {
          //  userName = (snap.snapshot.value as Map)["name"];
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => Dashboard()));
          } else {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackBar(
                "Driver is blocked :contact admin@gmail.com ", context);
          }
        } else {
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackBar("Driver does not exist", context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
             
            children: [

               const SizedBox(
                      height: 80,
                    ),
              Image.asset("assets/images/uberexec.png",width: 220,),

               const SizedBox(
                      height: 30,
                    ),
              const Text(
                "Login as a Driver",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              // text field iput
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          )),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: "password",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          )),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 10),
                      ),
                      child: const Text("Login"),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => SignupScreen()));
                        },
                        child: const Text(
                          "don't have an account? Register here",
                          style: TextStyle(color: Colors.grey),
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
