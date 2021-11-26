import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honours_project/Pages/AddLocationPage.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({
    Key? key,
  }) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => AddLocationPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('FishApp',
                  style: GoogleFonts.kalam(fontSize: 30, color: Colors.white)),
              SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation(Colors.lightGreenAccent[100]),
              ),
              Container(
                child: Image(
                  image: AssetImage('lib/assets/logo.png'),
                  width: 200,
                  height: 200,
                ),
              ),
            ],
          ),
        ));
  }
}
