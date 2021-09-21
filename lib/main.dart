import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
//import 'dart:js' as js;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page/login_form.dart';
import 'home_page/home_page.dart';
import 'util.dart';

//void main() {
//  runApp(MyApp());
//}

void main() {
  runApp(MaterialApp(
    title: 'Spotify Playlist Maker',
    home: HomePage(),
    builder: EasyLoading.init(),
  ));
}

// void configLoading() {
//   EasyLoading.instance
//     ..displayDuration = const Duration(milliseconds: 2000)
//     ..indicatorType = EasyLoadingIndicatorType.fadingCircle
//     ..loadingStyle = EasyLoadingStyle.dark
//     ..indicatorSize = 45.0
//     ..radius = 10.0
//     ..progressColor = Colors.yellow
//     ..backgroundColor = Colors.green
//     ..indicatorColor = Colors.yellow
//     ..textColor = Colors.yellow
//     ..maskColor = Colors.blue.withOpacity(0.5)
//     ..userInteractions = true
//     ..dismissOnTap = false;
// }
