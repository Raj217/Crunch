import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';

import 'package:crunch/utils/firebase/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProjectsHandler extends ChangeNotifier {
  final String _apiLink =
      'https://firestore.googleapis.com/v1/projects/crunch-6d707/databases/(default)/documents/users?key=AIzaSyAFcNxMLjN5hAaMsueXNB1lkXu3u56EaAw';
  late FirebaseFirestore _firestore;
  late FirebaseAuth _firebaseAuth;
  late FirebaseStorage _firebaseStorage;
  bool _isFireStoreAvailable = false;
  late GoogleSignIn _googleSignIn;
  late String appVersion;

  ProjectsHandler() {
    initAppVersion();
  }

  Future<void> initAppVersion() async {
    appVersion = (await PackageInfo.fromPlatform()).version;
  }

  /// For windows stream gets updated only when the timeStamp is changed
  final StreamController _streamController = StreamController.broadcast();
  Timestamp lastUpdate = Timestamp(0, 0);
  String createTime = '';
  String updateTime = '';
  List<String> currentProjects = [];
  Uint8List? profileImage;
  GoogleSignInAccount? _user;

  bool get isUserEmailVerified =>
      _firebaseAuth.currentUser?.emailVerified ?? false;
  User? get getCurrentUser => _firebaseAuth.currentUser;
  Uint8List? get getProfileImage => profileImage;
  Stream get getStream => _streamController.stream;
  String get getAppVersion => appVersion;

  set setUserName(String username) =>
      _firebaseAuth.currentUser?.updateDisplayName(username);

  Future<void> retrieveData() async {
    try {
      if (_firebaseAuth.currentUser?.email != null) {
        try {
          profileImage = await _firebaseStorage
              .ref('profile images/${_firebaseAuth.currentUser?.email}.jpg')
              .getData();
        } on PlatformException catch (e) {
          profileImage = null;
        }
        _firestore
            .doc('users/${_firebaseAuth.currentUser?.email}')
            .snapshots()
            .listen((project) {
          List? data = project.data()?.values.toList();
          for (Map project in data ?? []) {
            currentProjects.add(project['project name']);
          }
          data?.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
          _streamController.add(data?.reversed.toList());
        });
      }
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
  }

  Future<bool> connect() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _firebaseAuth = FirebaseAuth.instance;

      _firestore = FirebaseFirestore.instance;

      _firebaseStorage = FirebaseStorage.instance;

      _googleSignIn = GoogleSignIn();

      _isFireStoreAvailable = true;
      if (_firebaseAuth.currentUser != null) {
        await retrieveData();
      }
      return _firebaseAuth.currentUser != null;
    } on UnsupportedError catch (_) {
      return false; // TODO: Change in future
    }
  }

  Future<bool> doesEmailExistsInFirebase(String email) async {
    if (_isFireStoreAvailable) {
      if ((await _firebaseAuth.fetchSignInMethodsForEmail(email)).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  Future<void> setProfileImage(Uint8List? imgFile) async {
    profileImage = imgFile;
    notifyListeners();
    await saveProfileImage();
  }

  Future<void> saveProfileImage() async {
    if (profileImage != null) {
      String path = 'profile images/${_firebaseAuth.currentUser?.email}.jpg';
      Reference ref = _firebaseStorage.ref().child(path);
      await ref.putData(profileImage!);
    }
    return;
  }

  Future<String> createUser(
      String username, String email, String password) async {
    if (_isFireStoreAvailable) {
      try {
        await _firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password);
        _firebaseAuth.currentUser?.updateDisplayName(username);
        await saveProfileImage();

        if (!(_firebaseAuth.currentUser?.emailVerified ?? false)) {
          sendVerificationEmail();
          listenToVerification(onVerified: () async {
            _firestore.collection('users').doc(email).set({});

            await retrieveData();
            notifyListeners();
          });
          return 'check your mail for verification';
        }
      } on FirebaseAuthException catch (e) {
        return e.message ?? '';
      }
    }
    return '';
  }

  Future<String> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (!(_firebaseAuth.currentUser?.emailVerified ?? false)) {
        sendVerificationEmail();
        listenToVerification(onVerified: () async {
          _firestore.collection('users').doc(email).set({});

          await retrieveData();
          notifyListeners();
        });

        return 'please verify your mail(verification mail has been sent).';
      }

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      return e.message ?? '';
    }
    return '';
  }

  Future<void> googleSignIn() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;
    _user = googleUser;

    final googleAuth = await googleUser.authentication;

    final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    await _firebaseAuth.signInWithCredential(credentials);

    DocumentReference docRef = _firestore.collection('users').doc(_user!.email);
    docRef.get().then((doc) async {
      if (doc.exists) {
        await retrieveData();
      } else {
        _firebaseAuth.currentUser?.updateDisplayName(_user!.displayName);
        _firestore.collection('users').doc(_user!.email).set({});
      }
    });

    if (_user!.photoUrl != null) {
      profileImage = (await NetworkAssetBundle(Uri.parse(_user!.photoUrl!))
              .load(_user!.photoUrl!))
          .buffer
          .asUint8List();
      await saveProfileImage();
    }
    notifyListeners();
    return;
  }

  void listenToVerification({void Function()? onVerified}) {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _firebaseAuth.currentUser?.reload();
      if (_firebaseAuth.currentUser?.emailVerified == true) {
        timer.cancel();
        if (onVerified != null) {
          onVerified();
        }
      }
    });
  }

  Future<void> sendVerificationEmail() async {
    _firebaseAuth.currentUser?.sendEmailVerification();
  }

  Future<void> signOut() async {
    _googleSignIn.disconnect();
    await _firebaseAuth.signOut();
    notifyListeners();
    return;
  }

  Stream<String> sendResetPasswordLink(String email) async* {
    if (_isFireStoreAvailable) {
      try {
        _firebaseAuth.sendPasswordResetEmail(email: email);
        yield 'password reset link has been sent to your email';
      } on FirebaseAuthException catch (e) {
        yield e.message ?? '';
      }
    }
    yield '';
  }

  Stream<String> addProject({required String name, String? desc}) async* {
    String message = '';
    try {
      if (currentProjects.contains(name)) {
        yield 'Project with same name exists. Please change the name';
      } else if (name.contains('.')) {
        yield 'Project name cannot contain period(.)';
      } else {
        setData({
          'project name': name,
          'project description': desc,
          'board indices': [],
        });

        yield message;
      }
    } catch (e) {
      yield e.toString();
    }
  }

  Stream<String> setBoardNameAndDesc(
      {required String oldBoardName,
      required String newBoardName,
      required String desc}) async* {
    if (_isFireStoreAvailable) {
      try {
        if (oldBoardName != newBoardName &&
            currentProjects.contains(newBoardName)) {
          yield 'Project with same name exists. Please change the name';
        } else if (newBoardName.contains('.')) {
          yield 'Project name cannot contain period(.)';
        } else {
          DocumentSnapshot<Map<String, dynamic>> allData = await _firestore
              .collection('users')
              .doc(_firebaseAuth.currentUser?.email)
              .get();

          Map<String, dynamic> data = allData[oldBoardName];

          await deleteProject(oldBoardName);
          data['project name'] = newBoardName;
          data['project description'] = desc;
          print(data);
          await setData(data);
          yield '';
        }
      } catch (e) {
        yield e.toString();
      }
    }
  }

  Future<void> setData(Map<String, dynamic> newData) async {
    newData['timestamp'] = Timestamp.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch);
    if (_isFireStoreAvailable) {
      await _firestore
          .collection('users')
          .doc(_firebaseAuth.currentUser?.email)
          .update({newData['project name']: newData});
    } else {
      newData['timestamp'] = DateTime.fromMillisecondsSinceEpoch(
              newData['timestamp'].millisecondsSinceEpoch)
          .toUtc()
          .toString()
          .replaceAll(' ', 'T');
      http
          .patch(
              Uri.parse(
                  'https://firestore.googleapis.com/v1/projects/crunch-6d707/databases/(default)/documents/users?key=AIzaSyAFcNxMLjN5hAaMsueXNB1lkXu3u56EaAw/${_firebaseAuth.currentUser?.email}/'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({newData['project name']: newData}))
          .then((value) => print([value.body, value.statusCode]));
    }
    notifyListeners();
    return;
  }

  Future<String> deleteProject(String projectName) async {
    try {
      await _firestore
          .collection('users')
          .doc(_firebaseAuth.currentUser?.email)
          .update({projectName: FieldValue.delete()});
    } catch (e) {
      return e.toString();
    }

    return '';
  }

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
    if (_firebaseAuth.currentUser?.email != null) {
      List out = [];

      /// Current User
      Map currentUserProjects = data['documents']
          .where((element) =>
              element['name'].substring(element['name'].length -
                  _firebaseAuth.currentUser?.email!.length) ==
              _firebaseAuth.currentUser?.email)
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

    return {};
  }
}
