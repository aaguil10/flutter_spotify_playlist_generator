import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'playlist_cleaner_page.dart';

import '../spotify_calls.dart';
import '../util.dart';

class CleanerDetailPage extends StatefulWidget {
  CleanerDetailPage({Key key, @required this.playlistModel}) : super(key: key);

  final PlaylistModel playlistModel;

  @override
  _CleanerDetailPageState createState() => _CleanerDetailPageState();
}

class _CleanerDetailPageState extends State<CleanerDetailPage> {
  var showSearch = false;

  void _removeDuplicates() async {
    EasyLoading.show(status: 'removing duplicates...');
    try {
      final res = await removeDuplicates(widget.playlistModel.name);
      print('res: ${res}');
      await EasyLoading.showSuccess(
          'Removed $res tracks from ${widget.playlistModel.name}.');
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  void _removeHistory() async {
    EasyLoading.show(status: 'removing songs in your history...');
    try {
      final res = await removeTracksInHistory(widget.playlistModel.name);
      print('res: ${res}');
      await EasyLoading.showSuccess(
          'Removed $res tracks from ${widget.playlistModel.name}.');
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  void _sortTopArtist() async {
    EasyLoading.show(status: 'sorting playlist...');
    try {
      final res = await sortTopArtist(widget.playlistModel.name);
      print('res: ${res}');
      await EasyLoading.showSuccess(
          'Removed $res tracks from ${widget.playlistModel.name}.');
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlist Cleaner'),
      ),
      body: ListView(children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.transparent,
              width: 10.0,
            ),
          ),
          child: Text(widget.playlistModel.name),
        ),
        Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.transparent,
                width: 10.0,
              ),
            ),
            child: RaisedButton(
              onPressed: () {
                _removeDuplicates();
              },
              child: Text('Remove Duplicates'),
            )),
        Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.transparent,
                width: 10.0,
              ),
            ),
            child: RaisedButton(
              onPressed: () {
                _removeHistory();
              },
              child: Text('Remove Songs In History'),
            )),
        Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.transparent,
                width: 10.0,
              ),
            ),
            child: RaisedButton(
              onPressed: () {
                _sortTopArtist();
              },
              child: Text('Sort By Top Artist'),
            )),
      ]),
    );
  }
}
