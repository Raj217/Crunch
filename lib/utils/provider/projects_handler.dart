import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:crunch/utils/firebase/firebase_options.dart';

class ProjectsHandler extends ChangeNotifier {
  final String _apiLink =
      'https://firestore.googleapis.com/v1/projects/crunch-6d707/databases/(default)/documents/users?key=AIzaSyAFcNxMLjN5hAaMsueXNB1lkXu3u56EaAw';
  late FirebaseFirestore _firestore;

  final String _userName = 'rajdristant007@gmail.com';

  /// For windows stream gets updated only when the timeStamp is changed
  final StreamController _streamController = StreamController();
  Timestamp lastUpdate = Timestamp(0, 0);

  Future<void> connect() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firestore = FirebaseFirestore.instance;
      _firestore.doc('users/$_userName').snapshots().listen((project) {
        List? data = project.data()?.values.toList();
        data?.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
        _streamController.add(data?.reversed.toList());
      });
    } on UnsupportedError catch (_) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        http.read(Uri.parse(_apiLink)).then((val) async {
          Map cleanData = _cleanData(await json.decode(val));
          if (lastUpdate != cleanData['timestamp']) {
            _streamController.add(cleanData['value']);
            lastUpdate = cleanData['timestamp'];
          }
        });
      });
    }
    return;
  }

  Stream get getStream => _streamController.stream;

  dynamic _typeConverter({required dynamic val, required String type}) {
    switch (type) {
      case 'timestampValue':
        return Timestamp.fromMillisecondsSinceEpoch(
            DateTime.parse(val['timestampValue']).millisecondsSinceEpoch);
      case 'stringValue':
        return val['stringValue'];
      case 'integerValue':
        return int.parse(val['integerValue']);
      case 'arrayValue':
        val = val['arrayValue']['values'];
        if (val != null) {
          for (int i = 0; i < val.length; i++) {
            val[i] = _typeConverter(val: val[i], type: val[i].keys.toList()[0]);
          }
        }

        return val;
      case 'mapValue':
        Map decoded = {};
        val = val['mapValue']['fields'];
        if (val != null) {
          for (String key in val.keys) {
            decoded[key] =
                _typeConverter(val: val[key], type: val[key].keys.toList()[0]);
          }
        }
        return decoded;
      default:
        return null;
    }
  }

  Map _cleanData(dynamic data) {
    List out = [];

    /// Current User
    Map currentUserProjects = data['documents']
        .where((element) =>
            element['name']
                .substring(element['name'].length - _userName.length) ==
            _userName)
        .toList()[0];
    String updateTime = currentUserProjects['updateTime'];
    currentUserProjects = currentUserProjects['fields'];
    for (dynamic project in currentUserProjects.keys) {
      out.add(_typeConverter(
          val: currentUserProjects[project],
          type: currentUserProjects[project].keys.toList()[0]));
    }
    out.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
    return {
      'value': out.reversed.toList(),
      'timestamp': _typeConverter(
          val: {'timestampValue': updateTime}, type: 'timestampValue')
    };
  }
}
