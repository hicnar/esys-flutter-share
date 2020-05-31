import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class Share {
  static const MethodChannel _channel = const MethodChannel(
      'channel:github.com/orgs/esysberlin/esys-flutter-share');

  /// Sends a text to other apps.
  static void text(String title, String text, String mimeType,
      {Rect sharePositionOrigin}) {
    Map argsMap = <String, dynamic>{
      'title': '$title',
      'text': '$text',
      'mimeType': '$mimeType'
    };
    argsMap = _addRect(argsMap, sharePositionOrigin);
    _channel.invokeMethod('text', argsMap);
  }

  /// Sends a file to other apps.
  static Future<void> file(
      String title, String name, List<int> bytes, String mimeType, {String text = '', String subject = '', Rect sharePositionOrigin}) async {
    Map argsMap = <String, String>{
      'title': '$title',
      'name': '$name',
      'mimeType': '$mimeType',
      'subject': '$subject',
      'text': '$text'
    };

    final tempDir = await getTemporaryDirectory();
    final file = await new File(join(tempDir.path, name)).create();
    await file.writeAsBytes(bytes);
    argsMap = _addRect(argsMap, sharePositionOrigin);
    _channel.invokeMethod('file', argsMap);
  }

  /// Sends multiple files to other apps.
  static Future<void> files(
      String title, Map<String, List<int>> files, String mimeType,
      {String text = '', Rect sharePositionOrigin}) async {
    Map argsMap = <String, dynamic>{
      'title': '$title',
      'names': files.entries.toList().map((x) => x.key).toList(),
      'mimeType': mimeType,
      'text': '$text'
    };

    final tempDir = await getTemporaryDirectory();

    for (var entry in files.entries) {
      final file = await new File('${tempDir.path}/${entry.key}').create();
      await file.writeAsBytes(entry.value);
    }

    argsMap = _addRect(argsMap, sharePositionOrigin);

    _channel.invokeMethod('files', argsMap);
  }

  static Map<String, dynamic> _addRect(
      Map<String, dynamic> argsMap, Rect sharePositionOrigin) => Map.fromEntries({
        ...argsMap.entries,
          if (sharePositionOrigin != null)
            ...
            [
              MapEntry('originX', sharePositionOrigin.left),
              MapEntry('originY', sharePositionOrigin.top),
              MapEntry('originWidth', sharePositionOrigin.width),
              MapEntry('originHeight', sharePositionOrigin.height)
            ]
        }
    );
}
