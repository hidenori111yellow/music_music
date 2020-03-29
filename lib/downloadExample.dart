import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:music_music/pages/loading_page.dart';

import 'package:music_music/store.dart';
import 'package:music_music/pages/holder_page.dart';
import 'package:music_music/pages/web_page.dart';

List<BottomNavigationBarItem> bottomItems = [home(), holder(), web()];

BottomNavigationBarItem home() {
  return BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home"));
}

BottomNavigationBarItem holder() {
  return BottomNavigationBarItem(
      icon: Icon(Icons.list), title: Text("MySongs"));
}

BottomNavigationBarItem web() {
  return BottomNavigationBarItem(icon: Icon(Icons.web), title: Text('Search'));
}

var _contentIndex = 0;

final yt = YoutubeExplode();

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

  @override
  Widget build(BuildContext context) {
    if (Store.isLoading) return LoadingPage();

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (val) => setState(() => _contentIndex = val),
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
            _pageController.animateToPage(index,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOutCirc);
            _contentIndex = index;
          });
        },
        currentIndex: _contentIndex,
      ),
    );
  }
}

Widget homeWiget() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          child: Text(
            "download",
            style: TextStyle(color: Colors.black),
          ),
          onTap: () {
            print("download");
            // holderKey.currentState.setState(() {
            getInfo();
            // });
          },
        ),
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: InkWell(
              child: Text(
                "onStart",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                print("onStart");
                onStart();
              }),
        ),
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: InkWell(
              child: Text(
                "onStop",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                print("onStop");
                onStop();
              }),
        ),
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: InkWell(
              child: Text(
                "onPause",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                print("onPause");
                onPause();
              }),
        ),
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: InkWell(
              child: Text(
                "onResume",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                print("onResume");
                onResume();
              }),
        ),
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: InkWell(
              child: Text(
                "seekToPlay",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                print("seekToPlay");
                Duration dur = Duration(seconds: 30);
                seekToPlay(dur.inMilliseconds);
              }),
        ),
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: InkWell(
              child: Text(
                "here",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                print("here");
              }),
        ),
      ],
    ),
  );
}

Widget holderWiget(List<FileSystemEntity> files) {
  return Holder(
    files: files,
  );
}

Widget webWidget() {
  return WebPage();
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

Future<void> getInfo() async {
  // var url = "https://www.youtube.com/watch?v=5nmxDZSokzE";
  // var url = "https://www.youtube.com/watch?v=JGwWNGJdvx8";
  // var url = "https://www.youtube.com/watch?v=eq8r1ZTma08";
  // var url = "https://www.youtube.com/watch?v=WFsWrsQZgrA";
  // var url = "https://www.youtube.com/watch?v=_-q-wUB2H1U";
  var url = "https://www.youtube.com/watch?v=Bp9-Yh6tb68";

  var id = YoutubeExplode.parseVideoId(url);
  print(id);
  if (id == null) {
    print("id is null");
  }

  Directory appDocDirectory = await getApplicationDocumentsDirectory();

  Directory downloadsDirectory = Directory('${appDocDirectory.path}/downloads');

  downloadsDirectory.createSync();

  // Download the video.
  if (id != null) {
    await download(id);
  }
}

Future<void> download(String id) async {
  // Get the video media stream.
  var mediaStream = await yt.getVideoMediaStream(id);

  // Get the last audio track (the one with the highest bitrate).
  var audio = mediaStream.audio.last;

  // Compose the file name removing the unallowed characters in windows.
  var fileName =
      '${mediaStream.videoDetails.title}.${audio.container.toString()}'
          .replaceAll('Container.', '')
          .replaceAll(r'\', '')
          .replaceAll('/', '')
          .replaceAll('*', '')
          .replaceAll('?', '')
          .replaceAll('"', '')
          .replaceAll('<', '')
          .replaceAll('>', '')
          .replaceAll('|', '');

  Directory appDocDirectory = await getApplicationDocumentsDirectory();

  print('${appDocDirectory.path}/downloads/$fileName');

  var file = File('${appDocDirectory.path}/downloads/$fileName');

  // Open the file in appendMode.
  var output = file.openWrite(mode: FileMode.writeOnlyAppend);

  // Track the file download status.
  var len = audio.size;
  var count = 0;
  var oldProgress = -1;

  // Create the message and set the cursor position.
  var msg = 'Downloading `${mediaStream.videoDetails.title}`:  \n';
  print(msg);

  print(audio.audioEncoding);

  await Future.delayed(Duration(seconds: 10));

  // Listen for data received.
  await for (var data in audio.downloadStream()) {
    count += data.length;
    var progress = ((count / len) * 100).round();
    if (progress != oldProgress) {
      print('$progress%');
      oldProgress = progress;
    }
    output.add(data);
  }

  // await for (var i in audio.downloadStream()) {
  //   print("$i");
  // }

  print("there");

  await output.close();
}

Future<String> get _localPath async {
  Directory appDocDirectory = await getApplicationDocumentsDirectory();
  return appDocDirectory.path;
}
