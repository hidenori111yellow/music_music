import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as exploder;
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'package:music_music/pages/loading_page.dart';
import 'package:music_music/store.dart';
import 'package:music_music/pages/holder_page.dart';
import 'package:music_music/pages/web_page.dart';
import 'package:music_music/actions/download.dart';

typedef void WebControllerCallback(Completer<WebViewController> controller);

typedef void DisposeCallback();

List<BottomNavigationBarItem> bottomItems = [home(), holder(), web()];

BottomNavigationBarItem home() {
  return BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home"));
}

BottomNavigationBarItem holder() {
  return BottomNavigationBarItem(
      icon: Icon(FontAwesomeIcons.music), title: Text("MySongs"));
}

BottomNavigationBarItem web() {
  return BottomNavigationBarItem(icon: Icon(Icons.web), title: Text('Search'));
}

var _contentIndex = 0;

FlutterSound flutterSound = FlutterSound();

AudioCache sound;

class DownloadExample extends StatefulWidget {
  @override
  _DownloadExampleState createState() => _DownloadExampleState();
}

class _DownloadExampleState extends State<DownloadExample> {
  static final List<FileSystemEntity> files = List<FileSystemEntity>();

  Directory downloads;

  PageController _pageController =
      PageController(initialPage: 0, keepPage: true);

  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void initState() {
    _getTheDirectory();
    super.initState();
  }

  void _getTheDirectory() async {
    Store.isLoading = true;
    Directory appDocDirectory = await getApplicationDocumentsDirectory();

    downloads = Directory('${appDocDirectory.path}/downloads');

    downloads.exists().then((result) {
      if (result) {
        print("this exists");
        downloads.list().toList().then((list) {
          list.forEach((file) {
            files.add(file);
          });
        });

        Store.files = files;
      }
    });

    print("go");

    setState(() {
      Store.isLoading = false;
    });
  }

  void createDirectory() {}

  void animateToPage(int index) {
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 300), curve: Curves.easeOutCirc);
    _contentIndex = index;
  }

  Widget homeWiget() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/music_notes3.jpg'),
            // colorFilter: new ColorFilter.mode(
            //     Colors.black.withOpacity(0.7), BlendMode.dstATop),
            fit: BoxFit.cover),
      ),
      child: Center(),
    );
  }

  Widget holderWiget(List<FileSystemEntity> files) {
    return Holder(
      files: files,
    );
  }

  Widget webWidget() {
    return WebPage(
      controller: _controller,
      webControllerCallback: (val) => _controller = val,
      disposeCallback: () => _controller = Completer<WebViewController>(),
    );
  }

  FutureBuilder<WebViewController> _downloadButton(
      Completer<WebViewController> controller) {
    return FutureBuilder<WebViewController>(
      future: controller.future,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        if (controller.hasData) {
          return InkWell(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(Icons.file_download),
            ),
            onTap: () {
              controller.data.currentUrl().then((url) {
                print(url);
                Download(url);
              });
              // getInfo(url);
            },
          );
        }
        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Store.isLoading) return LoadingPage();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 28.0),
              child: InkWell(
                child: Text(
                  "Music Music",
                  style: TextStyle(color: Colors.yellow),
                ),
                onTap: () => animateToPage(0),
              ),
            ),
            Icon(
              Icons.music_note,
              color: Colors.pinkAccent,
            )
          ],
        ),
        actions: <Widget>[
          (_contentIndex == 2) ? _downloadButton(_controller) : Container(),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: (_contentIndex != 2)
            ? PageScrollPhysics()
            : NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _contentIndex = index),
        children: <Widget>[
          homeWiget(),
          holderWiget(files),
          webWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: bottomItems,
        onTap: (index) {
          setState(() {
            animateToPage(index);
          });
        },
        currentIndex: _contentIndex,
      ),
    );
  }
}

Future<void> onStart() async {
  String path = await _localPath;
  // var file =
  //     File("$path/downloads/Ed Sheeran - Shape of You [Official Video].webM");

  var file =
      File("$path/downloads/85 MORE Minutes of Relaxing Maplestory Music.webM");

  var uri = Uri.file(file.path);

  flutterSound.startPlayer(uri.toString());
}

Future<void> onStop() async {
  Future<String> result = flutterSound.stopPlayer();

  result.then((path) {
    print('stopPlayer: $path');
  });
}

Future<void> onPause() async {
  Future<String> result = flutterSound.pausePlayer();

  result.then((v) {
    print('pausePlayer: $v');
  });
}

Future<void> onResume() async {
  Future<String> result = flutterSound.resumePlayer();

  result.then((v) {
    print('resumePlayer: $v');
  });
}

Future<void> seekToPlay(int sec) async {
  Future<String> result = flutterSound.seekToPlayer(sec);

  result.then((v) {
    print('seekToPlayer: $v');
  });
}

Future<String> get _localPath async {
  Directory appDocDirectory = await getApplicationDocumentsDirectory();
  return appDocDirectory.path;
}
