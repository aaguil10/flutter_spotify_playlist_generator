import 'package:flutter/material.dart';

class TopArtistAppBar extends StatefulWidget implements PreferredSizeWidget {
  static const scrollTop = 'Scroll Top';
  static const scrollMiddle = 'Scroll Middle';
  static const scrollBottom = 'Scroll Bottom';
  static const scrollBlacklist = 'Scroll Blacklist';

  TopArtistAppBar(
      {Key key,
      @required this.onQueryChanged,
      @required this.onScrollChanged,
      @required this.onSaveClicked})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onScrollChanged;
  final ValueChanged<void> onSaveClicked;

  @override
  final Size preferredSize;

  @override
  _TopArtistAppBarState createState() => _TopArtistAppBarState();
}

class _TopArtistAppBarState extends State<TopArtistAppBar> {
  String _searchText = '';
  final _filter = TextEditingController();
  var showSearch = false;

  _TopArtistAppBarState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = '';
          widget.onQueryChanged(_searchText);
        });
      } else {
        setState(() {
          _searchText = _filter.text;
          widget.onQueryChanged(_searchText);
        });
      }
    });
  }

  void _searchPressed() {
    setState(() {
      showSearch = !showSearch;
      _filter.clear();
    });
  }

  Widget _headerActionButtons() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      onSelected: (String result) {
        setState(() {
          widget.onScrollChanged(result);
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: TopArtistAppBar.scrollTop,
          child: Text(TopArtistAppBar.scrollTop),
        ),
        const PopupMenuItem<String>(
          value: TopArtistAppBar.scrollMiddle,
          child: Text(TopArtistAppBar.scrollMiddle),
        ),
        const PopupMenuItem<String>(
          value: TopArtistAppBar.scrollBottom,
          child: Text(TopArtistAppBar.scrollBottom),
        ),
        const PopupMenuItem<String>(
          value: TopArtistAppBar.scrollBlacklist,
          child: Text(TopArtistAppBar.scrollBlacklist),
        ),
      ],
    );
  }

  AppBar _buildSearchBar() => AppBar(
        title: TextField(
          controller: _filter,
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              prefixIcon: Icon(Icons.search),
              hintText: 'Search...'),
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: _searchPressed,
              )),
        ],
      );

  AppBar _buildAppBar() => AppBar(
        title: Text('Top Artists'),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: _searchPressed,
              )),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  // _saveTopArtist();
                  setState(() {
                    widget.onSaveClicked(null);
                  });
                },
                child: Icon(Icons.save),
              )),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  // scrollTo(10);
                  print('clicked dots');
                },
                child: _headerActionButtons(),
              )),
        ],
      );

  Widget build(BuildContext context) {
    return showSearch ? _buildSearchBar() : _buildAppBar();
  }
}

// var filteredNames = List(); // names filtered by search text
// var _searchIcon = Icon(Icons.search);
// Widget _appBarTitle = Text('Top Artists');
// String _searchText = "";
// Icon _searchIconData = new Icon(Icons.search);
//
// void _searchPressed() {
//   setState(() {
//     if (this._searchIcon.icon == Icons.search) {
//       this._searchIcon = new Icon(Icons.close);
//       this._appBarTitle = new TextField(
//         controller: _filter,
//         decoration: new InputDecoration(
//             prefixIcon: new Icon(Icons.search), hintText: 'Search...'),
//       );
//     } else {
//       this._searchIcon = new Icon(Icons.search);
//       this._appBarTitle = new Text('Top Artists');
//       filteredNames = [top, middle, bottom, blackList];
//       _filter.clear();
//     }
//   });
// }

// Widget _buildBar(BuildContext context) {
//   return AppBar(
//     title: _appBarTitle,
//     actions: <Widget>[
//       Padding(
//           padding: EdgeInsets.only(right: 20.0),
//           child: IconButton(
//             icon: _searchIcon,
//             onPressed: _searchPressed,
//           )),
//       Padding(
//           padding: EdgeInsets.only(right: 20.0),
//           child: GestureDetector(
//             onTap: () {
//               _saveTopArtist();
//             },
//             child: Icon(Icons.save),
//           )),
//       Padding(
//           padding: EdgeInsets.only(right: 20.0),
//           child: GestureDetector(
//             onTap: () {
//               scrollTo(10);
//             },
//             child: _headerActionButtons(),
//           )),
//     ],
//   );
// }
