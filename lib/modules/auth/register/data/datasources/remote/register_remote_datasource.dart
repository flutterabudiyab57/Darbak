import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../../core/constants/api_path.dart';
class RegisterRemoteDatasource {
  Future<Map<String, dynamic>> signup(Map<String, String> data, String path) async {
    var request = http.MultipartRequest("POST", Uri.parse(mainApi + '/register'));

    request.files.add(await http.MultipartFile.fromPath("licenceFace", path));
    request.headers.addAll({"Accept": "application/json"});
    request.fields.addAll(data);

    var response = await request.send();
    var responseBytes = await response.stream.toBytes();
    var responseBody = utf8.decode(responseBytes);
    var decoded = json.decode(responseBody);
    print("📩 Register  data: $data");
    print("📩 Register API Response: $decoded");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return decoded;
    } else {
      throw Exception(jsonEncode(decoded));
    }
  }

  Future<void> verifyOtp(String userId, String otp) async {
    final url = Uri.parse(mainApi + '/register/verify');

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
      },
      body: {
        "user_id": userId,
        "code": otp,
      },
    );

    final responseBody = json.decode(response.body);

    print("📩 Verify OTP Response: $responseBody");

    if (response.statusCode == 200) {
      return Future.value();
    } else {
      throw Exception(responseBody['message'] ?? 'OTP verification failed');
    }
  }
}