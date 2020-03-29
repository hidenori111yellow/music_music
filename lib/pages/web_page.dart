import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatefulWidget {
  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return WebView(
          initialUrl: 'https://www.youtube.com/?gl=JP&hl=ja',
          javascriptMode: JavascriptMode.unrestricted,
        );
      },
    );
  }
}
