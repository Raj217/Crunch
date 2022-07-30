import 'package:crunch/utils/google/google_utils.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';

class GoogleDrive {
  DriveApi? _driveApi;

  Future<void> initDriveApi({required GoogleSignInAccount user}) async {
    final headers = await user.authHeaders;
    final client = GoogleAuthClient(headers);
    _driveApi = DriveApi(client);
    return;
  }

  Future<void> upload(
      {required String folderName,
      required dynamic data,
      required String fileName}) async {
    if (_driveApi != null) {
    } else {
      throw Exception('driveApi not initialised');
    }
  }
}
