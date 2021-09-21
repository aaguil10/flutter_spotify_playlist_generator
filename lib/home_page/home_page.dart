import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import '../login_page/login_page.dart';
import '../full_lib_page/full_lib_page.dart';
import '../all_of_artist/all_of_artist.dart';
import '../top_artist_page/top_artist_page.dart';
import '../playlist_cleaner_page/playlist_cleaner_page.dart';

import 'package:playlist_generator_w_history/spotify_calls.dart';

class HomePage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var isLoggedIn = true;

  Icon _buildIcon(IconData iconData) => Icon(
        iconData,
        color: Colors.lightBlue,
        size: 40.0,
      );

  void _displayComingSoon(BuildContext context) {
    final snackBar = SnackBar(content: Text('Coming Soon!'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void _saveHistory() async {
    EasyLoading.show(status: 'Saving history...');
    try {
      final res = await saveHistory();
      print('res: ${res}');
      await EasyLoading.showSuccess('${res}');
    } catch (e) {
      print('e: $e');
      EasyLoading.showError(e);
    }
  }

  void _debug() async {
    EasyLoading.show(status: 'Debug...');
    try {
      final res = await debug();
      print('res: ${res}');
      await EasyLoading.showSuccess('${res}');
    } catch (e) {
      print('e: $e');
      EasyLoading.showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: ListView(
          children: <Widget>[
            Card(
              child: ListTile(
                  leading: _buildIcon(Icons.history),
                  title: Text('Save History'),
                  subtitle: Text('Saves last 50 songs played'),
                  onTap: () {
                    _saveHistory();
                  }),
            ),
            Card(
              child: ListTile(
                  leading: _buildIcon(Icons.person),
                  title: Text('Log In'),
                  subtitle: Text('Log in to Spotify'),
                  onTap: () {
                    print("AHHHHHH");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }),
            ),
            Card(
              child: ListTile(
                  leading: _buildIcon(Icons.library_music_rounded),
                  title: Text('Full Library'),
                  subtitle:
                      Text('Generate playlist with all your favorite songs.'),
                  onTap: () {
                    if (!isLoggedIn) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FullLibPage()),
                    );
                  }),
            ),
            Card(
              child: ListTile(
                  leading: _buildIcon(Icons.favorite),
                  title: Text('Top Artists'),
                  subtitle: Text('Generate list of your favorite artist.'),
                  onTap: () {
                    if (!isLoggedIn) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TopArtistPage()),
                    );
                  }),
            ),
            Card(
              child: ListTile(
                  leading: FlutterLogo(),
                  title: Text('Bubble List'),
                  subtitle: Text('Shows all the artist related to each other.'),
                  onTap: () {
                    if (!isLoggedIn) return;
                    _displayComingSoon(context);
                  }),
            ),
            Card(
              child: ListTile(
                  leading: _buildIcon(Icons.all_inclusive),
                  title: Text('All of Artist'),
                  subtitle: Text('Generate list of all the songs from artist.'),
                  onTap: () {
                    if (!isLoggedIn) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AllOfArtistPage()),
                    );
                  }),
            ),
            Card(
              child: ListTile(
                  leading: _buildIcon(Icons.cleaning_services_outlined),
                  title: Text('Playlist Cleaner'),
                  subtitle:
                      Text('Removes duplicates, played songs, and sort them.'),
                  onTap: () {
                    if (!isLoggedIn) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlaylistCleanerPage()),
                    );
                  }),
            ),
            // Card(
            //   child: ListTile(
            //       leading: _buildIcon(Icons.bug_report_outlined),
            //       title: Text('Debug'),
            //       subtitle: Text('Do not Click@#!'),
            //       onTap: () {
            //         if (!isLoggedIn) return;
            //         _debug();
            //       }),
            // ),
          ],
        ));
  }
}
