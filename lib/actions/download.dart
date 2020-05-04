import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as exploder;

class Download {
  final yt = exploder.YoutubeExplode();

  Download(String url) {
    getInfo(url);
  }

  Future<void> getInfo(String url) async {
    var id = exploder.YoutubeExplode.parseVideoId(url);
    print(id);
    if (id == null) {
      print("id is null");
    }

    Directory appDocDirectory = await getApplicationDocumentsDirectory();

    Directory downloadsDirectory =
        Directory('${appDocDirectory.path}/downloads');

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

    await output.close();
  }
}
