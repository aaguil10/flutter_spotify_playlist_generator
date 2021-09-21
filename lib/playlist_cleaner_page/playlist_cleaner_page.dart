import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../spotify_calls.dart';
import '../util.dart';
import 'cleaner_detail_page.dart';

class PlaylistCleanerPage extends StatefulWidget {
  @override
  _PlaylistCleanerPageState createState() => _PlaylistCleanerPageState();
}

class _PlaylistCleanerPageState extends State<PlaylistCleanerPage> {
  final pageMessage = 'This page creates a playlist with every song you like. '
      'This playlist will the be used to find your favorite artists. '
      'Please type what you want to call the playlist and select what playlist '
      'you would like to use.---';

  final myController = TextEditingController();

  var playlists = <PlaylistModel>[];

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  void _getPlaylist() async {
    EasyLoading.show(status: 'loading playlists...');
    try {
      final res = await getPlaylists();
      playlists = <PlaylistModel>[]; // Clear array
      print('res: ${res.length}');
      setState(() {
        var count = 0;
        for (final item in res) {
          final id = item['id'];
          final name = item['name'];
          final total = item['tracks'].length > 0 ? item['tracks']['total'] : 0;
          final imageUrl = item['images'].length > 0
              ? item['images'][item['images'].length - 1]['url']
              : null;
          playlists.add(PlaylistModel(id, name, total, imageUrl));
        }
      });
      EasyLoading.dismiss();
    } catch (e) {
      print('e: $e');
      EasyLoading.showError(errorMsg);
    }
  }

  Widget _buildCheckbox(int index) {
    final playlist = playlists[index];
    return ListTile(
        leading: playlist.imageUrl != null
            ? Image(
                image: NetworkImage(playlist.imageUrl),
              )
            : Icon(Icons.music_note),
        title: Text(playlist.name),
        subtitle: Text('${playlist.total} tracks'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CleanerDetailPage(playlistModel: playlist)),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _getPlaylist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlist Cleaner'),
      ),
      body: RefreshIndicator(
          displacement: 0,
          onRefresh: () async {
            _getPlaylist();
          },
          child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return _buildCheckbox(index);
              })),
    );
  }
}

class PlaylistModel {
  String id;
  String name;
  int total;
  String imageUrl;

  PlaylistModel(this.id, this.name, this.total, this.imageUrl);
}
