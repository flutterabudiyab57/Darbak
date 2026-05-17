import 'dart:developer';

import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/constants/preferences_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileDataSource {
  Future<void> editProfile({
    required String image,
    required String licenceImage,
    required Map<String, String> data,
  }) async {
    try {
      var item = http.MultipartRequest("POST", Uri.parse(mainApi + '/profile'));

      if (image != "") {
        item.files.add(
          await http.MultipartFile.fromPath(
            "avatar",
            image,
          ),
        );
        log("… Avatar image added");
      }

      if (licenceImage != "") {
        log("ðŸ”µ Adding licence image...");
        item.files.add(
          await http.MultipartFile.fromPath(
            "licenceFace",
            licenceImage,
          ),
        );
        log("… Licence image added");
      }

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

      String? token = sharedPreferences.getString(PreferencesConstants.token);


      if (token == null || token.isEmpty) {
        log("an ERROR: Token is null or empty!");
        throw Exception("Authentication token not found. Please login again.");
      }

      item.headers.addAll({
        "Accept": "application/json",
        'Authorization': "Bearer $token",
        "Accept-Language": langCode == '' ? "en" : langCode
      });

      item.fields.addAll(data);

      var response = await item.send();

      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        log("… Profile updated successfully");
      } else {
        log("an Error: Status code ${response.statusCode}");
        log("an Error body: $responseBody");
        throw Exception("Failed to update profile. Status: ${response.statusCode}, Body: $responseBody");
      }
    } catch (e) {
      log("an Exception occurred: $e");
      throw Exception(e);
    }
  }
}