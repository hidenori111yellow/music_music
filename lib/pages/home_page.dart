import 'package:flutter/material.dart';
import 'package:music_music/downloadExample.dart';
import 'package:music_music/pages/loading_page.dart';
import 'package:music_music/store.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    if (Store.isLoading) return LoadingPage();

    return DownloadExample();
  }
}
