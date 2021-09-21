import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../spotify_calls.dart';
import '../util.dart';
import 'top_artist_app_bar.dart';
import 'artist_layout_model.dart';

class TopArtistPage extends StatefulWidget {
  @override
  _TopArtistPageState createState() => _TopArtistPageState();
}

class _TopArtistPageState extends State<TopArtistPage> {
  final myController = TextEditingController();
  var top = <dynamic>[];
  var middle = <dynamic>[];
  var bottom = <dynamic>[];
  var blackList = <dynamic>[];
  static const moveTopText = 'Move Top';
  static const moveMiddleText = 'Move Middle';
  static const moveBottomText = 'Move Bottom';
  static const moveBlackText = 'Move Black List';
  static const topKey = 'top';
  static const middleKey = 'middle';
  static const bottomKey = 'bottom';
  static const blackListKey = 'black_list';
  final topOptions = <String>[moveMiddleText, moveBottomText, moveBlackText];
  final middleOptions = <String>[moveTopText, moveBottomText, moveBlackText];
  final bottomOptions = <String>[moveTopText, moveMiddleText, moveBlackText];
  final blackOptions = <String>[moveTopText, moveMiddleText, moveBottomText];
  final pageMessage =
      'Enter the name of the playlist that you want to use to count how many '
      'songs you have for each artist. After you can add them to your top, '
      'bottom, or black lists to sort them even more.';
  // List<ArtistLayoutModel> layoutItems;
  List<ArtistLayoutModel> _searchResults;
  String searchQuery = '';

  // Controller to scroll or jump to a particular item.
  final ItemScrollController itemScrollController = ItemScrollController();

  /// Listener that reports the position of items when the list is scrolled.
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  void scrollTo(int index) => itemScrollController.scrollTo(
      index: index,
      curve: Curves.easeInOutCubic,
      duration: Duration(seconds: 2));

  List<ArtistLayoutModel> _buildLayoutItems(
      List<dynamic> topItems,
      List<dynamic> middleItems,
      List<dynamic> bottomItems,
      List<dynamic> blackItems) {
    final result = [
      ArtistLayoutModel(ListItemType.topSection),
      ArtistLayoutModel(
          ListItemType.header, null, 'Top Artist', null, Category.top),
    ];
    for (final item in topItems) {
      result.add(ArtistLayoutModel(ListItemType.item, item['id'], item['name'],
          item['count'].toString(), Category.top));
    }
    result.add(ArtistLayoutModel(
        ListItemType.header, null, 'Middle Artist', null, Category.middle));
    for (final item in middleItems) {
      result.add(ArtistLayoutModel(ListItemType.item, item['id'], item['name'],
          item['count'].toString(), Category.middle));
    }
    result.add(ArtistLayoutModel(
        ListItemType.header, null, 'Bottom Artist', null, Category.bottom));
    for (final item in bottomItems) {
      result.add(ArtistLayoutModel(ListItemType.item, item['id'], item['name'],
          item['count'].toString(), Category.bottom));
    }
    result.add(ArtistLayoutModel(
        ListItemType.header, null, 'Blacklist Artist', null, Category.black));
    for (final item in blackItems) {
      result.add(ArtistLayoutModel(ListItemType.item, item['id'], item['name'],
          item['count'].toString(), Category.black));
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _populatePlaylistNameField();
    _searchResults = <ArtistLayoutModel>[];
    _getTopArtist();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    _saveTopArtist();
    super.dispose();
  }

  void _populatePlaylistNameField() async {
    var name = (await SharedPreferences.getInstance())
        .getString(playlistNameTopArtist);
    if (name == null) {
      name = (await SharedPreferences.getInstance())
          .getString(playlistNameFullLib);
      ;
    }
    setState(() {
      myController.text = name;
    });
  }

  void _buildTopArtist() async {
    EasyLoading.show(status: 'building list...');
    try {
      (await SharedPreferences.getInstance())
          .setString(playlistNameTopArtist, myController.text);

      final res = await generateTopArtist(myController.text);
      print('_buildTopArtist: $res');
      EasyLoading.dismiss();
    } catch (_) {
      EasyLoading.showError(errorMsg);
    }
    await _getTopArtist();
  }

  void _getTopArtist() async {
    EasyLoading.show(status: 'loading artists...');
    try {
      final res = await getTopArtistData();
      setState(() {
        top = res[topKey];
        middle = res[middleKey];
        bottom = res[bottomKey];
        blackList = res[blackListKey];
        updateSearchResults();
      });
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.showError(errorMsg);
    }
  }

  void _saveTopArtist() async {
    EasyLoading.show(status: 'saving artists...');
    final res = await saveTopArtistData({
      topKey: top,
      middleKey: middle,
      bottomKey: bottom,
      blackListKey: blackList
    });
    print('_saveTopArtist: $res');
    EasyLoading.dismiss();
    if (res == 'Success') {
      await EasyLoading.showSuccess(savedMsg);
    } else {
      await EasyLoading.showError(errorMsg);
    }
  }

  void moveItemTop(dynamic item) {
    setState(() {
      _removeItemFromLists(item);
      top.add(item);
      updateSearchResults();
    });
  }

  void moveItemMiddle(dynamic item) {
    setState(() {
      _removeItemFromLists(item);
      middle.add(item);
      updateSearchResults();
    });
  }

  void moveItemBottom(dynamic item) {
    setState(() {
      _removeItemFromLists(item);
      bottom.add(item);
      updateSearchResults();
    });
  }

  void moveItemBlack(dynamic item) {
    setState(() {
      _removeItemFromLists(item);
      blackList.add(item);
      updateSearchResults();
    });
  }

  void _removeItemFromLists(dynamic item) {
    top.remove(item);
    middle.remove(item);
    bottom.remove(item);
    blackList.remove(item);
  }

  DropdownButton<String> dropdownButton(dynamic item, List<String> options) =>
      DropdownButton<String>(
        icon: Icon(Icons.more_vert),
        onChanged: (String newValue) {
          if (newValue == moveTopText) {
            moveItemTop(item);
          } else if (newValue == moveMiddleText) {
            moveItemMiddle(item);
          } else if (newValue == moveBottomText) {
            moveItemBottom(item);
          } else {
            moveItemBlack(item);
          }
        },
        items: options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );

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
            RaisedButton(
              onPressed: () {
                _buildTopArtist();
              },
              child: Text('Build'),
            )
          ]));

  Widget _buildTopHeader() => Container(
      decoration: BoxDecoration(
        color: Colors.green[800],
        border: Border.all(
          color: Colors.transparent,
          width: 10.0,
        ),
      ), //       <--- BoxDecoration here
      child: Text(
        'Top Artists',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ));

  Widget _buildMiddleHeader() => Container(
      decoration: BoxDecoration(
        color: Colors.yellow[800],
        border: Border.all(
          color: Colors.transparent,
          width: 10.0,
        ),
      ), //       <--- BoxDecoration here
      child: Text(
        'Middle Artists',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ));

  Widget _buildBottomHeader() => Container(
      decoration: BoxDecoration(
        color: Colors.red[800],
        border: Border.all(
          color: Colors.transparent,
          width: 10.0,
        ),
      ), //       <--- BoxDecoration here
      child: Text(
        'Bottom Artists',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ));

  Widget _buildBlackHeader() => Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        border: Border.all(
          color: Colors.transparent,
          width: 10.0,
        ),
      ), //       <--- BoxDecoration here
      child: Text(
        'Black List',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ));

  Widget _buildListItem(int index) {
    var item = _searchResults[index];
    if (item.listItem == ListItemType.topSection) {
      return _buildTopSection();
    }
    if (item.listItem == ListItemType.header) {
      if (item.category == Category.top) {
        return _buildTopHeader();
      }
      if (item.category == Category.middle) {
        return _buildMiddleHeader();
      }
      if (item.category == Category.bottom) {
        return _buildBottomHeader();
      }
      if (item.category == Category.black) {
        return _buildBlackHeader();
      }
    }
    if (item.listItem == ListItemType.item) {
      Color tileColor;
      var options;
      Map<String, dynamic> element;
      if (item.category == Category.top) {
        tileColor = Colors.green[50];
        options = topOptions;
        element = getElementWithId(item.id, top);
      }
      if (item.category == Category.middle) {
        tileColor = Colors.yellow[50];
        options = middleOptions;
        element = getElementWithId(item.id, middle);
      }
      if (item.category == Category.bottom) {
        tileColor = Colors.red[50];
        options = bottomOptions;
        element = getElementWithId(item.id, bottom);
      }
      if (item.category == Category.black) {
        tileColor = Colors.black12;
        options = blackOptions;
        element = getElementWithId(item.id, blackList);
      }
      return ListTile(
        tileColor: tileColor,
        title: Text(item.name),
        subtitle: Text('Count: ${item.sub}'),
        trailing: dropdownButton(element, options),
      );
    }
  }

  dynamic getElementWithId(String id, List<dynamic> elementList) =>
      elementList.firstWhere((element) => element['id'] == id, orElse: null);

  List<Map<String, dynamic>> filterdList(List<dynamic> items, String newValue) {
    List<Map<String, dynamic>> result = [];
    for (final item in items) {
      if (item['name'].toString().toLowerCase().contains(newValue)) {
        result.add(item);
      }
    }
    return result;
  }

  void _handleSaveClick(_) {
    _saveTopArtist();
  }

  void _handleScrollChanged(String val) {
    if (val == TopArtistAppBar.scrollTop) {
      scrollTo(1);
    } else if (val == TopArtistAppBar.scrollMiddle) {
      scrollTo(top.length + 2);
    } else if (val == TopArtistAppBar.scrollBottom) {
      scrollTo(top.length + middle.length + 3);
    } else {
      scrollTo(top.length + middle.length + bottom.length + 4);
    }
  }

  void _handleSearchChanged(String newValue) {
    searchQuery = newValue;
    updateSearchResults();
  }

  void updateSearchResults() {
    setState(() {
      if (searchQuery == '') {
        _searchResults = _buildLayoutItems(top, middle, bottom, blackList);
      } else {
        _searchResults = _buildLayoutItems(
            filterdList(top, searchQuery),
            filterdList(middle, searchQuery),
            filterdList(bottom, searchQuery),
            filterdList(blackList, searchQuery));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('_searchResults: $_searchResults');
    return Scaffold(
      appBar: TopArtistAppBar(
        onQueryChanged: _handleSearchChanged,
        onScrollChanged: _handleScrollChanged,
        onSaveClicked: _handleSaveClick,
      ),
      body: RefreshIndicator(
          displacement: 0,
          onRefresh: () async {
            _getTopArtist();
          },
          child: ScrollablePositionedList.builder(
            itemCount: (_searchResults?.length ?? 0),
            itemBuilder: (BuildContext ctxt, int index) {
              return _buildListItem(index);
            },
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
          )),
    );
  }
}
