import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../spotify_calls.dart';
import '../util.dart';
import 'login_form.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  String name = '';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _testLogIn() async {
    print('tacos');
    EasyLoading.show(status: 'loading...');
    final me = await getMe();
    print('_testLogIn: $me');
    setState(() {
      if (me != null) {
        widget.name = 'Hi $me, get ready to find some jammers!';
      } else {
        widget.name = 'Please log in...';
      }
    });
    EasyLoading.dismiss();
  }

  _launchURL() async {
//    if (await _hasAccessToken()) {
//      return;
//    }
//    js.context.callMethod("open", [loginUrl]);
    if (await canLaunch(loginUrl)) {
      await launch(loginUrl);
    } else {
      throw 'Could not launch $loginUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Log In"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(loginMessage),
            RaisedButton(
              onPressed: () {
                _launchURL();
              },
              child: Text('Log In'),
            ),
            LogInForm(),
            RaisedButton(
              onPressed: () {
                _testLogIn();
              },
              child: Text('Test'),
            ),
            Text(widget.name)
          ],
        ),
      ),
    );
  }
}
