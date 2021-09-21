import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../spotify_calls.dart';
import '../util.dart';

class FullLibPage extends StatefulWidget {
  @override
  _FullLibPageState createState() => _FullLibPageState();
}

class _FullLibPageState extends State<FullLibPage> {
  final pageMessage = 'This page creates a playlist with every song you like. '
      'This playlist will the be used to find your favorite artists. '
      'Please type what you want to call the playlist and select what playlist '
      'you would like to use.---';

  final myController = TextEditingController();

  var playlists = <PlaylistModel>[
    PlaylistModel(likedSongsPlaylistId, 'Liked Songs')
  ];

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  void _populatePlaylistNameField() async {
    var name =
        (await SharedPreferences.getInstance()).getString(playlistNameFullLib);
    if (name == null) {
      name = 'full_lib';
    }
    setState(() {
      myController.text = name;
    });
  }

  void _getPlaylist() async {
    EasyLoading.show(status: 'loading playlists...');
    final res = await getPlaylists();
    try {
      playlists = <PlaylistModel>[
        PlaylistModel('liked_songs', 'Liked Songs')..selected = true
      ]; // Clear array
      setState(() {
        for (final item in res) {
          playlists.add(PlaylistModel(item['id'], item['name']));
        }
      });
      EasyLoading.dismiss();
    } catch (_) {
      EasyLoading.showError(errorMsg);
    }
  }

  void _callGeneratePlaylist() async {
    EasyLoading.show(status: 'generating playlist...');
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(playlistNameFullLib, myController.text);

      final playlistIds = <String>[];
      for (final playlist in playlists) {
        if (playlist.selected) {
          playlistIds.add(playlist.id);
        }
      }
      final res = await generateFullLib(myController.text, playlistIds);
      print('_callGeneratePlaylist: $res');
      EasyLoading.showSuccess(successMsg);
    } catch (_) {
      EasyLoading.showError(errorMsg);
    }
  }

  Widget _buildTopSection() => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.transparent,
          width: 10.0,
        ),
      ), //       <--- BoxDecoration here
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(pageMessage),
            TextFormField(
              controller: myController,
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
          ]));

  Widget _buildBottomSection() => Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.transparent,
            width: 10.0,
          )), //       <--- BoxDecoration here
      child: RaisedButton(
        onPressed: () {
          _callGeneratePlaylist();
        },
        child: Text('Generate Playlist'),
      ));

  Widget _buildCheckbox(int index) {
    if (index == 0) {
      return _buildTopSection();
    }
    if (index == playlists.length + 1) {
      return _buildBottomSection();
    }
    final playlist = playlists[index - 1];
    return LabeledCheckbox(
      label: playlist.name,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      value: playlist.selected,
      onChanged: (bool newValue) {
        setState(() {
          playlist.selected = newValue;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _populatePlaylistNameField();
    _getPlaylist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Library'),
      ),
      body: RefreshIndicator(
          displacement: 0,
          onRefresh: () async {
            _getPlaylist();
          },
          child:
              // ListView(children: <Widget>[
              //   Container(
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(12),
              //         border: Border.all(
              //           color: Colors.transparent,
              //           width: 10.0,
              //         ),
              //       ), //       <--- BoxDecoration here
              //       child: Column(
              //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //           children: <Widget>[
              //             Text(pageMessage),
              //             TextFormField(
              //               controller: myController,
              //               validator: (value) {
              //                 if (value.isEmpty) {
              //                   return 'Please paste code from browser';
              //                 }
              //                 return null;
              //               },
              //               decoration: InputDecoration(
              //                 labelText: 'Playlist Name',
              //               ),
              //             ),
              //           ])),
              //   buildCheckboxes(),
              //   Container(
              //       decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(12),
              //           border: Border.all(
              //             color: Colors.transparent,
              //             width: 10.0,
              //           )), //       <--- BoxDecoration here
              //       child: RaisedButton(
              //         onPressed: () {
              //           _callGeneratePlaylist();
              //         },
              //         child: Text('Generate Playlist'),
              //       ))
              // ])
              ListView.builder(
                  itemCount: playlists.length + 2,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return _buildCheckbox(index);
                  })),
    );
  }
}

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    this.label,
    this.padding,
    this.value,
    this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label)),
            Checkbox(
              value: value,
              onChanged: (bool newValue) {
                onChanged(newValue);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PlaylistModel {
  String id;
  String name;
  bool selected = false;

  PlaylistModel(this.id, this.name);
}
