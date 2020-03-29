import 'package:flutter/material.dart';
import 'package:music_music/YoutubeMP3.dart';
import 'package:music_music/downloadExample.dart';

import 'package:music_music/pages/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SLAYER Leecher',
      theme:
          ThemeData(primarySwatch: Colors.blue, accentColor: Colors.red[400]),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
