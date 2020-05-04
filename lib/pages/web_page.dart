import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:music_music/downloadExample.dart';

class WebPage extends StatefulWidget {
  WebPage({this.controller, this.webControllerCallback, this.disposeCallback});

  final Completer<WebViewController> controller;
  final WebControllerCallback webControllerCallback;
  final DisposeCallback disposeCallback;
  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  @override
  void dispose() {
    widget.disposeCallback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Builder(
        builder: (BuildContext context) {
          return WebView(
            initialUrl: 'https://www.youtube.com/?gl=JP&hl=ja',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webController) {
              widget.controller.complete(webController);
              widget.webControllerCallback(widget.controller);
            },
          );
        },
      ),
    );
  }
}
