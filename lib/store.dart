import 'dart:io';
import 'package:flutter/material.dart';

// ignore: avoid_classes_with_only_static_members
class Store {
  // static GlobalKey<MyHomePageState> homePageKey = GlobalKey<MyHomePageState>();
  // static GlobalKey<ScaffoldState> homePageScaffoldKey;
  // static GlobalKey homePageScaffoldChildKey;
  static bool isLoading = false;
  // static bool isFirstLogin = false;
  static bool isSignedIn = false;
  static String token = '';
  static List<FileSystemEntity> files;

  // static bool isDebugMode = false;

  // static const Duration snackbarDuration = Duration(seconds: 5);
  // static const Duration connectionKeepAlive = Duration(seconds: 10);

  // static bool get isNotSignedIn => !isSignedIn;
}
