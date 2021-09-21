import 'package:flutter/material.dart';
import '../spotify_calls.dart';
import '../util.dart';

class AllOfArtistPage extends StatefulWidget {
  @override
  _AllOfArtistPageState createState() => _AllOfArtistPageState();
}

class _AllOfArtistPageState extends State<AllOfArtistPage> {
  final _formKey = GlobalKey<FormState>();
  final artistIdTextController = TextEditingController();
  final playlistIdTextController = TextEditingController();
  bool _isSelected = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    artistIdTextController.dispose();
    playlistIdTextController.dispose();
    super.dispose();
  }

  void _callGeneratePlaylist() async {
    print('No tacos');
    final res = await generateAllOfArtist(
        artistIdTextController.text, playlistIdTextController.text);
    print('_callGeneratePlaylist: $res');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const pageMessage =
        'This page creates a playlist with every song you like. '
        'This playlist will the be used to find your favorite artists. '
        'Please type what you want to call the playlist and select what playlist '
        'you would like to use. First Add artist id, then playlist name.';

    return Scaffold(
      appBar: AppBar(
        title: Text('Full Library'),
      ),
      body: ListView(children: <Widget>[
        Text(pageMessage),
        TextFormField(
          controller: artistIdTextController,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please paste code from browser';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: 'Artist Id',
          ),
        ),
        TextFormField(
          controller: playlistIdTextController,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please paste code from browser';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: 'Playlist Name',
          ),
        ),
        RaisedButton(
          onPressed: () {
            _callGeneratePlaylist();
          },
          child: Text('Generate Artist Playlist'),
        ),
      ]),
    );
  }
}
