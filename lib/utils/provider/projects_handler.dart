import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';

import 'package:crunch/utils/firebase/firebase_options.dart';

class ProjectsHandler extends ChangeNotifier {
  final String _apiLink =
      'https://firestore.googleapis.com/v1/projects/crunch-6d707/databases/(default)/documents/users?key=AIzaSyAFcNxMLjN5hAaMsueXNB1lkXu3u56EaAw';
  late FirebaseFirestore _firestore;
  bool _isFireStoreAvailable = false;
  final String _userMail = 'rajdristant007@gmail.com';

  /// For windows stream gets updated only when the timeStamp is changed
  final StreamController _streamController = StreamController();
  Timestamp lastUpdate = Timestamp(0, 0);
  String createTime = '';
  String updateTime = '';

  Future<void> connect() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firestore = FirebaseFirestore.instance;
      _firestore.doc('users/$_userMail').snapshots().listen((project) {
        List? data = project.data()?.values.toList();
        data?.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
        _streamController.add(data?.reversed.toList());
      });
      _isFireStoreAvailable = true;
    } on UnsupportedError catch (e) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        http.read(Uri.parse(_apiLink)).then((data) async {
          Map cleanData = _cleanData(await json.decode(data));

          if (lastUpdate != cleanData['timestamp']) {
            _streamController.add(cleanData['value']);
            lastUpdate = cleanData['timestamp'];
          }
        });
      });
    }

    return;
  }

  Future<void> setData(Map<String, dynamic> newData) async {
    newData['timestamp'] = Timestamp.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch);
    if (_isFireStoreAvailable) {
      await _firestore
          .collection('users')
          .doc(_userMail)
          .update({newData['project name']: newData});
    } else {
      newData['timestamp'] = DateTime.fromMillisecondsSinceEpoch(
              newData['timestamp'].millisecondsSinceEpoch)
          .toUtc()
          .toString()
          .replaceAll(' ', 'T');
      print(newData);
      http
          .patch(
              Uri.parse(
                  'https://firestore.googleapis.com/v1/projects/crunch-6d707/databases/(default)/documents/users?key=AIzaSyAFcNxMLjN5hAaMsueXNB1lkXu3u56EaAw/$_userMail/'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({newData['project name']: newData}))
          .then((value) => print([value.body, value.statusCode]));
    }
  }

  Stream get getStream => _streamController.stream;

  Map<String, dynamic> _typeConverterToFirestoreFormat(dynamic val) {
    switch (val.runtimeType) {
      case String:
        return {'stringValue': val};
      case int:
        return {'integerValue': val.toString()};
      case Timestamp:
        return {
          "timestampValue":
              DateTime.now().toUtc().toString().replaceAll(' ', 'T')
        };
      case Map:
        Map<String, dynamic> out = {
          "mapValue": {"fields": {}}
        };
        for (String key in val.keys) {
          out['mapValue']['fields'][key] =
              _typeConverterToFirestoreFormat(val[key]);
        }
        return out;
      case List:
        Map<String, dynamic> out = {
          "arrayValue": {"values": []}
        };
        for (dynamic v in val) {
          out["arrayValue"]["values"].add(_typeConverterToFirestoreFormat(v));
        }
        return out;
      default:
        return {};
    }
  }

  dynamic _typeConverterToNormal({required dynamic val, required String type}) {
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
            val[i] = _typeConverterToNormal(
                val: val[i], type: val[i].keys.toList()[0]);
          }
        }

        return val;
      case 'mapValue':
        Map decoded = {};
        val = val['mapValue']['fields'];
        if (val != null) {
          for (String key in val.keys) {
            decoded[key] = _typeConverterToNormal(
                val: val[key], type: val[key].keys.toList()[0]);
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
                .substring(element['name'].length - _userMail.length) ==
            _userMail)
        .toList()[0];

    updateTime = currentUserProjects['updateTime'];
    createTime = currentUserProjects['createTime'];
    currentUserProjects = currentUserProjects['fields'];
    for (dynamic project in currentUserProjects.keys) {
      out.add(_typeConverterToNormal(
          val: currentUserProjects[project],
          type: currentUserProjects[project].keys.toList()[0]));
    }
    out.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

    return {
      'value': out.reversed.toList(),
      'timestamp': _typeConverterToNormal(
          val: {'timestampValue': updateTime}, type: 'timestampValue')
    };
  }
}
