import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:music_music/store.dart';

GlobalKey holderKey = GlobalKey<HolderState>();

class ItemData {
  ItemData(this.title, this.key);

  final String title;

  // Each item in reorderable list needs stable and unique key
  final Key key;
}

enum DraggingMode {
  iOS,
  Android,
}

class Holder extends StatefulWidget {
  final List<FileSystemEntity> files;

  Holder({this.files});

  @override
  HolderState createState() => HolderState();
}

class HolderState extends State<Holder> {
  List<ItemData> _fileItems = List<ItemData>();

  FlutterSound flutterSound = FlutterSound();

  Key beforeTaped;

  @override
  void initState() {
    _setFileData(widget.files);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _setFileData(List<FileSystemEntity> files) async {
    if (_fileItems.isNotEmpty) {
    } else {
      int count = 0;
      files.forEach((entity) {
        if (entity is File) {
          String fileName = path.basename(entity.path);
          _fileItems.add(ItemData(
              fileName.substring(0, fileName.indexOf(".")), ValueKey(count)));
          count++;
        }
      });
    }
  }

  int _indexOfKey(Key key) {
    return _fileItems.indexWhere((ItemData d) => d.key == key);
  }

  bool _reorderCallback(Key item, Key newPosition) {
    int draggingIndex = _indexOfKey(item);
    int newPositionIndex = _indexOfKey(newPosition);

    final draggedItem = _fileItems[draggingIndex];
    setState(() {
      debugPrint("Reordering $item -> $newPosition");
      var tmp = Store.files[draggingIndex];
      Store.files.removeAt(draggingIndex);
      Store.files.insert(newPositionIndex, tmp);
      _fileItems.removeAt(draggingIndex);
      _fileItems.insert(newPositionIndex, draggedItem);
    });
    return true;
  }

  void _reorderDone(Key item) {
    final draggedItem = _fileItems[_indexOfKey(item)];
    debugPrint("Reordering finished for ${draggedItem.title}}");
  }

  DraggingMode _draggingMode = DraggingMode.iOS;

  @override
  Widget build(BuildContext context) {
    return ReorderableList(
      onReorder: this._reorderCallback,
      onReorderDone: this._reorderDone,
      child: ListView.builder(
          // separatorBuilder: (context, index) => Divider(
          //       color: Colors.black,
          //     ),
          itemCount: widget.files.length,
          itemBuilder: (context, index) {
            return HolderItem(
              data: _fileItems[index],
              isFirst: index == 0,
              isLast: index == _fileItems.length - 1,
              draggingMode: _draggingMode,
              flutterSound: flutterSound,
              beforeTaped: beforeTaped,
              file: Store.files[index],
              beforTapedCallback: (val) => setState(() => beforeTaped = val),
            );
          }),
    );
  }
}

typedef void BeforeTapedCallback(Key val);

class HolderItem extends StatefulWidget {
  HolderItem(
      {this.data,
      this.isFirst,
      this.isLast,
      this.draggingMode,
      this.flutterSound,
      this.file,
      this.beforeTaped,
      this.beforTapedCallback});

  final ItemData data;
  final bool isFirst;
  final bool isLast;
  final DraggingMode draggingMode;
  final FlutterSound flutterSound;
  final FileSystemEntity file;
  final Key beforeTaped;
  final BeforeTapedCallback beforTapedCallback;

  @override
  _HolderItemState createState() => _HolderItemState();
}

class _HolderItemState extends State<HolderItem> {
  Widget _buildChild(BuildContext context, ReorderableItemState state) {
    BoxDecoration decoration;

    if (state == ReorderableItemState.dragProxy ||
        state == ReorderableItemState.dragProxyFinished) {
      // slightly transparent background white dragging (just like on iOS)
      decoration = BoxDecoration(color: Color(0xD0FFFFFF));
    } else {
      bool placeholder = state == ReorderableItemState.placeholder;
      decoration = BoxDecoration(
          border: Border(
              top: widget.isFirst && !placeholder
                  ? Divider.createBorderSide(context, color: Colors.black) //
                  : BorderSide.none,
              bottom: widget.isLast && placeholder
                  ? BorderSide.none //
                  : Divider.createBorderSide(context, color: Colors.black)),
          color: placeholder ? null : Colors.white);
    }

    // For iOS dragging mode, there will be drag handle on the right that triggers
    // reordering; For android mode it will be just an empty container
    Widget dragHandle = widget.draggingMode == DraggingMode.iOS
        ? ReorderableListener(
            child: Container(
              padding: EdgeInsets.only(right: 18.0, left: 18.0),
              color: Color(0x08000000),
              child: Center(
                child: Icon(Icons.reorder, color: Color(0xFF888888)),
              ),
            ),
          )
        : Container();

    Widget content = Container(
      decoration: decoration,
      child: SafeArea(
          top: true,
          bottom: false,
          child: Opacity(
            // hide content for placeholder
            opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
            child: Slidable(
              actionPane: SlidableDrawerActionPane(),
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () {},
                ),
              ],
              child: ListTile(
                  title: Text(widget.data.title,
                      style: Theme.of(context).textTheme.subhead),
                  onTap: () {
                    if (widget.beforeTaped != widget.data.key) {
                      widget.flutterSound.stopPlayer();
                      widget.flutterSound.startPlayer(widget.file.path);
                    } else {
                      if (widget.flutterSound.audioState ==
                          t_AUDIO_STATE.IS_PLAYING) {
                        widget.flutterSound.pausePlayer();
                      } else if (widget.flutterSound.audioState ==
                          t_AUDIO_STATE.IS_PAUSED) {
                        widget.flutterSound.resumePlayer();
                      } else {
                        widget.flutterSound.startPlayer(widget.file.path);
                      }
                    }
                    widget.beforTapedCallback(widget.data.key);
                  }),
            ),
          )),
    );

    // For android dragging mode, wrap the entire content in DelayedReorderableListener
    // if (widget.draggingMode == DraggingMode.Android) {
    content = DelayedReorderableListener(
      child: content,
    );
    // }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableItem(
        key: widget.data.key, //
        childBuilder: _buildChild);
  }
}
