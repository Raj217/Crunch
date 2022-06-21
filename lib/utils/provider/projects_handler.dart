import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:io';
import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/firebase/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ProjectsHandler extends ChangeNotifier {
  final String _apiLink =
      'https://firestore.googleapis.com/v1/projects/crunch-6d707/databases/(default)/documents/users?key=AIzaSyAFcNxMLjN5hAaMsueXNB1lkXu3u56EaAw';

  late FirebaseFirestore _firestore;
  late FirebaseAuth _firebaseAuth;
  late FirebaseStorage _firebaseStorage;
  late FirebaseRemoteConfig _firebaseRemoteConfig;
  late GoogleSignIn _googleSignIn;
  late String appVersion;

  ProjectsHandler() {
    initAppVersion();
  }

  /// For windows stream gets updated only when the timeStamp is changed
  final StreamController _streamController = StreamController.broadcast();
  final StreamController<double> _downloadStreamController =
      StreamController<double>.broadcast();
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
  Stream<double> get getDownloadStreamProgress =>
      _downloadStreamController.stream;
  Future<bool> get isNewAppVersionAvailable async {
    await _firebaseRemoteConfig.fetchAndActivate();
    return !(_firebaseRemoteConfig.getString('version') == appVersion);
  }

  Future<bool> get doesProfileImageExists async {
    String path = 'profile images/${_firebaseAuth.currentUser?.email}.jpg';
    Reference ref = _firebaseStorage.ref().child(path);
    try {
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  set setUserName(String username) =>
      _firebaseAuth.currentUser?.updateDisplayName(username);

  // ----------------------------------- App Download ----------------------------------
  Future<void> downloadUpdate() async {
    if (await Permission.storage.request().isGranted &&
        await Permission.requestInstallPackages.request().isGranted) {
    } else {
      await [Permission.storage, Permission.requestInstallPackages].request();
    }
    if (await Permission.storage.request().isGranted &&
        await Permission.requestInstallPackages.request().isGranted) {
      try {
        if (await isNewAppVersionAvailable) {
          String appName =
              'crunch_v${_firebaseRemoteConfig.getString('version')}.apk';
          Directory? extDir = await getExternalStorageDirectory();
          String filePath = '${extDir?.path}/$appName';
          final file = File(filePath);
          if (file.existsSync()) {
            await OpenFile.open(filePath);
          } else {
            List<int> _bytes = [];
            int _received = 0;
            Reference ref =
                _firebaseStorage.ref().child('app release/$appName');

            http.StreamedResponse _response = await http.Client().send(
                http.Request('GET', Uri.parse(await ref.getDownloadURL())));
            int _total = _response.contentLength ?? 0;

            _response.stream.listen((value) {
              _bytes.addAll(value);
              _received += value.length;
              _downloadStreamController.add(_received / _total);
            }).onDone(() async {
              await file.writeAsBytes(_bytes);
              await OpenFile.open(filePath);
            });
          }
        }
      } catch (e) {
        print(e);
        return;
      }
    }

    return;
  }

  // ----------------------------------- Data ----------------------------------
  Future<void> initAppVersion() async {
    appVersion = (await PackageInfo.fromPlatform()).version;
  }

  Future<bool> connect() async {
    if (await Permission.storage.request().isGranted) {
    } else {
      await Permission.storage.request();
    }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _firebaseAuth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _firebaseStorage = FirebaseStorage.instance;
    _googleSignIn = GoogleSignIn();
    _firebaseRemoteConfig = FirebaseRemoteConfig.instance;

    Directory? extDir = await getExternalStorageDirectory();
    File file = File(
        '${extDir?.path}/crunch_v${_firebaseRemoteConfig.getString('version')}.apk');
    if (await file.exists()) {
      await file.delete();
    }

    await _firebaseRemoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 1),
      minimumFetchInterval: const Duration(seconds: 1),
    ));

    await _firebaseRemoteConfig.setDefaults({'version': appVersion});

    if (_firebaseAuth.currentUser != null) {
      await retrieveData();
    }
    return _firebaseAuth.currentUser != null &&
        _firebaseAuth.currentUser!.emailVerified;
  }

  Future<void> retrieveData() async {
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
  }

  Future<bool> doesEmailExistsInFirebase(String email) async {
    if ((await _firebaseAuth.fetchSignInMethodsForEmail(email)).isNotEmpty) {
      return true;
    }
    return false;
  }

  // ------------------------------ Profile Image -----------------------------
  Future<void> setProfileImage(
    Uint8List? imgFile,
  ) async {
    profileImage = imgFile;
    await _saveProfileImage();
    notifyListeners();
  }

  Future<void> _saveProfileImage() async {
    if (profileImage != null) {
      profileImage = await FlutterImageCompress.compressWithList(profileImage!);
      String path = 'profile images/${_firebaseAuth.currentUser?.email}.jpg';
      Reference ref = _firebaseStorage.ref().child(path);
      await ref.putData(profileImage!);
    }
    return;
  }

  Future<void> deleteProfileImage() async {
    String path = 'profile images/${_firebaseAuth.currentUser?.email}.jpg';
    Reference ref = _firebaseStorage.ref().child(path);

    profileImage = null;
    await ref.delete();
    return;
  }

  // ----------------------------------- Sign Up ----------------------------------
  Future<String> createUser(String username, String email, String password,
      {Uint8List? img}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      _firebaseAuth.currentUser?.updateDisplayName(username);

      profileImage = img;
      await _saveProfileImage();

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
    return '';
  }

  // ----------------------------------- Login ----------------------------------
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

    if (_user!.photoUrl != null && !(await doesProfileImageExists)) {
      profileImage = (await NetworkAssetBundle(Uri.parse(_user!.photoUrl!))
              .load(_user!.photoUrl!))
          .buffer
          .asUint8List();

      await _saveProfileImage();
    }
    notifyListeners();
    return;
  }

  // -------------------------------- Listeners -------------------------------
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

  // ------------------------------- Send Links ------------------------------
  Future<void> sendVerificationEmail() async {
    _firebaseAuth.currentUser?.sendEmailVerification();
  }

  Stream<String> sendResetPasswordLink(String email) async* {
    try {
      _firebaseAuth.sendPasswordResetEmail(email: email);
      yield 'password reset link has been sent to your email';
    } on FirebaseAuthException catch (e) {
      yield e.message ?? '';
    }

    yield '';
  }

  // --------------------------------- Sign Out--------------------------------
  Future<void> signOut() async {
    _googleSignIn.disconnect();
    await _firebaseAuth.signOut();
    notifyListeners();
    return;
  }

  // ----------------------- Project Create, Read, delete -----------------------
  Stream<String> addProject({required String name, String? desc}) async* {
    String message = '';
    try {
      if (currentProjects.contains(name)) {
        yield 'Project with same name exists. Please change the name';
      } else if (name.contains('.') ||
          name.contains('/') ||
          name.contains('~') ||
          name.contains('*') ||
          name.contains('[') ||
          name.contains(']')) {
        yield 'Project name cannot contain ./~*[]';
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

  Future<void> setData(Map<String, dynamic> newData) async {
    newData['timestamp'] = Timestamp.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch);

    await _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser?.email)
        .update({newData['project name']: newData});

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
}
