import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util.dart';

// Create a Form widget.
class LogInForm extends StatefulWidget {
  @override
  LogInFormState createState() {
    return LogInFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class LogInFormState extends State<LogInForm> {
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  void _saveTokens(String text) async {
    final val = json.decode(text);
    print(val[accessTokenKey]);
    print(val[refreshTokenKey]);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('access_token', val[accessTokenKey]);
    prefs.setString('refresh_token', val[refreshTokenKey]);
    await EasyLoading.showSuccess('Saved!');
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: myController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please paste code from browser';
              }
              try {
                json.decode(value);
              } catch (e) {
                return 'Please make sure to copy ALL THE TEXT. Click Log in again';
              }
              return null;
            },
          ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: RaisedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false
                    // otherwise.
                    if (_formKey.currentState.validate()) {
                      _saveTokens(myController.text);
                    }
                  },
                  child: Text('Submit'),
                ),
              )),
        ],
      ),
    );
  }
}
