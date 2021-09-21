import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'util.dart';

Future<String> accessToken() async =>
    (await SharedPreferences.getInstance()).getString(accessTokenKey);
Future<String> refreshToken() async =>
    (await SharedPreferences.getInstance()).getString(refreshTokenKey);

Future<void> updateTokens(String text) async {
  print('Got values: $text');
  final val = json.decode(text);
  print(val[accessTokenKey]);
  print(val[refreshTokenKey]);

  final oldAccess = await accessToken();
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(accessTokenKey, val[accessTokenKey]);
  final newAccess = await accessToken();
  if (oldAccess != newAccess || newAccess == '') {
    print('newAccess updated successfully: $newAccess');
  } else {
    print('newAccess NOT updated: $newAccess');
  }
}

Future<String> getMe([bool retry = true]) async {
  print('getting me...');

  final response = await http.post(
    meUrl,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      accessTokenKey: await accessToken(),
      refreshTokenKey: await refreshToken(),
    }),
  );

  if (response.statusCode == 200) {
    final res = json.decode(response.body)['data'];
    print('response: ${res}');
    final message = res['message'];
    if (message == 'Unauthorized') {
      print('need to refresh token');
      final refreshTok = await refreshToken();
      print('refreshTok: $refreshTok');
      if (refreshTok != null) {
        print('no moco');
        final refresh_response =
            await http.get('$refreshTokenUrl?refresh_token=$refreshTok');
        await updateTokens(refresh_response.body);
        if (retry) {
          getMe(false);
        }
      }
    }
    return res['display_name'];
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Get Me call failed');
  }
}

Future<List<dynamic>> getPlaylists([bool retry = true]) async {
  final response = await http.post(
    playlistUrl,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      accessTokenKey: await accessToken(),
      refreshTokenKey: await refreshToken(),
    }),
  );

  if (response.statusCode == 200) {
    final status = json.decode(response.body)['status'];
    final res = json.decode(response.body)['data'];
    if (status == 'Success') {
      return res;
    }
    print('Taco1 res: $res');
    try {
      final message = res['message'];
      if (message == 'Unauthorized') {
        print('need to refresh token');
        final refresh_response = await http
            .get('$refreshTokenUrl?refresh_token=${await refreshToken()}');
        await updateTokens(refresh_response.body);
        print('updated');
        if (retry) {
          print('Retrying......');
          return getPlaylists(false);
        }
      }
    } catch (e) {
      print('Something went wrong');
      throw Exception('Get getPlaylists failed: ${res}');
    }
  } else {
    print('If the server did not return a 200 OK response');
    print('response: ${response}');
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Get getPlaylists failed');
  }
}

Future<String> generateFullLib(String title, List<String> ids,
    [bool retry = true]) async {
  final response = await http.post(
    generateFullLibUrl,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      accessTokenKey: await accessToken(),
      refreshTokenKey: await refreshToken(),
      'playlist_ids': jsonEncode(ids),
      'playlist_name': title,
    }),
  );

  if (response.statusCode == 200) {
    final status = json.decode(response.body)['status'];
    final res = json.decode(response.body)['data'];
    print('----res: $res');
    if (status == successText) {
      return successText;
    }
    try {
      final message = res['message'];
      if (message == 'Unauthorized') {
        print('need to refresh token');
        final refresh_response = await http
            .get('$refreshTokenUrl?refresh_token=${await refreshToken()}');
        await updateTokens(refresh_response.body);
        if (retry) {
          return generateFullLib(title, ids, false);
        }
      }
    } catch (e) {}
    return errorText;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    return errorText;
  }
}

Future<List<dynamic>> generateAllOfArtist(
    String artistId, String playlistName) async {
  final response = await http.post(
    getAllSongsFromArtist,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      accessTokenKey: await accessToken(),
      refreshTokenKey: await refreshToken(),
      'artist_id': artistId,
      'playlist_name': playlistName,
    }),
  );

  if (response.statusCode == 200) {
    final res = json.decode(response.body)['data'];
    try {
      final message = res['message'];
      if (message == 'Unauthorized') {
        print('need to refresh token');
        final refresh_response = await http
            .get('$refreshTokenUrl?refresh_token=${await refreshToken()}');
        await updateTokens(refresh_response.body);
      }
    } catch (e) {
      print('Error occured');
    }
    print('Ahhhh: $res');
    return res;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Get Me call failed');
  }
}

Future<String> generateTopArtist(String playlistName,
    [bool retry = true]) async {
  print('generateTopArtist retry: $retry');
  final response = await http.post(
    buildTopArtist,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      accessTokenKey: await accessToken(),
      refreshTokenKey: await refreshToken(),
      'playlist_name': playlistName,
    }),
  );

  if (response.statusCode == 200) {
    final res = json.decode(response.body)['data'];
    if (res == 'Success') {
      return res;
    }
    try {
      final message = res['message'];
      if (message == 'Unauthorized') {
        print('need to refresh token');
        final refresh_response = await http
            .get('$refreshTokenUrl?refresh_token=${await refreshToken()}');
        await updateTokens(refresh_response.body);
        return generateTopArtist(playlistName, false);
      }
    } catch (e) {
      print('Error occurred');
    }
    return res.toString();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('buildTopArtist call failed');
  }
}

Future<Map<String, dynamic>> getTopArtistData([bool retry = true]) async {
  final response = await http.post(
    getTopArtist,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      accessTokenKey: await accessToken(),
      refreshTokenKey: await refreshToken(),
    }),
  );

  if (response.statusCode == 200) {
    final status = json.decode(response.body)['status'];
    final res = json.decode(response.body)['data'];
    print('res: ${res}');
    if (status == 'Success') {
      final val = json.decode(res);
      print('val: ${val['middle'].length}');
      return val;
    }
    try {
      final message = res['message'];
      if (message == 'Unauthorized') {
        print('need to refresh token');
        print('await refreshToken(): ${await refreshToken()}');
        final refresh_response = await http
            .get('$refreshTokenUrl?refresh_token=${await refreshToken()}');
        await updateTokens(refresh_response.body);
        return getTopArtistData(false);
      }
    } catch (e) {
      print('Error occurred');
    }
    return {'error': res.toString()};
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('getTopArtist call failed');
  }
}

Future<String> saveTopArtistData(Map<String, List<dynamic>> data,
    [bool retry = true]) async {
  final response = await http.post(
    saveTopArtist,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      accessTokenKey: await accessToken(),
      refreshTokenKey: await refreshToken(),
      topArtistDataKey: jsonEncode(data)
    }),
  );

  if (response.statusCode == 200) {
    final status = json.decode(response.body)['status'];
    final res = json.decode(response.body)['data'];
    print('Save artist data res: $res');
    if (status == 'Success') {
      return 'Success';
    }
    try {
      final message = res['message'];
      if (message == 'Unauthorized') {
        print('need to refresh token');
        final refresh_response = await http
            .get('$refreshTokenUrl?refresh_token=${await refreshToken()}');
        await updateTokens(refresh_response.body);
        print('After update');
        return saveTopArtistData(data, false);
      }
    } catch (e) {
      print('Error occurred');
    }
    print('No Tcao');
    return 'Error';
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    print('No Tcao 2');
    return 'Error';
  }
}

Future<String> removeDuplicates(String playlistName,
    [bool retry = true]) async {
  final response = await http.post(
    removeDuplicatesUrl,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      accessTokenKey: await accessToken(),
      refreshTokenKey: await refreshToken(),
      playlistNameCleaner: playlistName
    }),
  );

  if (response.statusCode == 200) {
    final status = json.decode(response.body)['status'];
    final res = json.decode(response.body)['data'];
    print('Save removeDuplicates res: $res');
    if (status == 'Success') {
      return res.toString();
    }
    try {
      final message = res['message'];
      if (message == 'Unauthorized') {
        print('need to refresh token');
        final refresh_response = await http
            .get('$refreshTokenUrl?refresh_token=${await refreshToken()}');
        await updateTokens(refresh_response.body);
        print('After update');
        return removeDuplicates(playlistName, false);
      }
    } catch (e) {
      print('Error occurred');
    }
    throw Exception('Error code: 1');
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Error code: 2');
  }
}

Future<String> saveHistory([bool retry = true]) async {
  final response = await http.post(
    saveHistoryUrl,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      accessTokenKey: await accessToken(),
      refreshTokenKey: await refreshToken(),
    }),
  );

  if (response.statusCode == 200) {
    final status = json.decode(response.body)['status'];
    final res = json.decode(response.body)['data'];
    print('Save history res: $res');
    if (status == 'Success') {
      return res.toString();
    }
    try {
      final message = res['message'];
      if (message == 'Unauthorized') {
        print('need to refresh token');
        final refresh_response = await http
            .get('$refreshTokenUrl?refresh_token=${await refreshToken()}');
        await updateTokens(refresh_response.body);
        print('After update');
        return saveHistory(false);
      }
    } catch (e) {
      print('Error occurred');
    }
    throw Exception('Error code: 1');
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Error code: 2');
  }
}

Future<String> removeTracksInHistory(String playlistName,
    [bool retry = true]) async {
  final response = await http.post(
    removeHistoryUrl,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      accessTokenKey: await accessToken(),
      refreshTokenKey: await refreshToken(),
      playlistNameCleaner: playlistName
    }),
  );

  if (response.statusCode == 200) {
    final status = json.decode(response.body)['status'];
    final res = json.decode(response.body)['data'];
    print('Save removeTracksInHistory res: $res');
    if (status == 'Success') {
      return res.toString();
    }
    try {
      final message = res['message'];
      if (message == 'Unauthorized') {
        print('need to refresh token');
        final refresh_response = await http
            .get('$refreshTokenUrl?refresh_token=${await refreshToken()}');
        await updateTokens(refresh_response.body);
        print('After update');
        return removeTracksInHistory(playlistName, false);
      }
    } catch (e) {
      print('Error occurred');
    }
    throw Exception('Error code: 1');
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Error code: 2');
  }
}

Future<String> sortTopArtist(String playlistName, [bool retry = true]) async {
  final response = await http.post(
    sortTopArtistUrl,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      accessTokenKey: await accessToken(),
      refreshTokenKey: await refreshToken(),
      playlistNameCleaner: playlistName
    }),
  );

  if (response.statusCode == 200) {
    final status = json.decode(response.body)['status'];
    final res = json.decode(response.body)['data'];
    print('Save sortTopArtist res: $res');
    if (status == 'Success') {
      return res.toString();
    }
    try {
      final message = res['message'];
      if (message == 'Unauthorized') {
        print('need to refresh token');
        final refresh_response = await http
            .get('$refreshTokenUrl?refresh_token=${await refreshToken()}');
        await updateTokens(refresh_response.body);
        print('After update');
        return sortTopArtist(playlistName, false);
      }
    } catch (e) {
      print('Error occurred');
    }
    throw Exception('Error code: 1');
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Error code: 2');
  }
}

Future<String> debug([bool retry = true]) async {
  final response = await http.post(
    buildGraph,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      accessTokenKey: await accessToken(),
      refreshTokenKey: await refreshToken(),
    }),
  );

  if (response.statusCode == 200) {
    final status = json.decode(response.body)['status'];
    final res = json.decode(response.body)['data'];
    print('Debug res: $res');
    if (status == 'Success') {
      return res.toString();
    }
    try {
      final message = res['message'];
      if (message == 'Unauthorized') {
        print('need to refresh token');
        final refresh_response = await http
            .get('$refreshTokenUrl?refresh_token=${await refreshToken()}');
        await updateTokens(refresh_response.body);
        print('After update');
        return debug(false);
      }
    } catch (e) {
      print('Error occurred');
    }
    throw Exception('Error code: 1');
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Error code: 2');
  }
}
