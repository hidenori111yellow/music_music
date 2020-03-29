import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_music/Models/YouTubeVideo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_extractor/youtube_extractor.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:toast/toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class YoutubeMP3 extends StatefulWidget {
  @override
  _YoutubeMP3State createState() => _YoutubeMP3State();
}

class _YoutubeMP3State extends State<YoutubeMP3> {
  TextEditingController videoURL = new TextEditingController();
  Result video;
  bool isFetching = false;
  bool fetchSuccess = false;
  bool isDownloading = false;
  bool downloadsuccess = false;
  String status = "Download ";
  String progress = "";

  Map<String, String> headers = {
    "X-Requested-With": "XMLHttpRequest",
  };

  Map<String, String> body;

  void insertBody(String videoURL) {
    body = {"url": videoURL, "ajax": "1"};
  }

  var extractor = YouTubeExtractor();

  Future<void> getInfo() async {
    var url = "https://www.youtube.com/watch?v=JGwWNGJdvx8";
    var ye = YoutubeExplode();
    var id = YoutubeExplode.parseVideoId(url);
    print(id);
    var mediaStreams = ye.getVideoMediaStream(id);
    var video = ye.getVideo(id);
    video.then((v) {
      print(v.title);
    });
    mediaStreams.then((data) {
      print(data.audio[1].itag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          child: Text(
            "here",
            style: TextStyle(color: Colors.black),
          ),
          onTap: () {
            print("taped");
            getInfo();
          },
        ),
      ),
    );
  }
}
