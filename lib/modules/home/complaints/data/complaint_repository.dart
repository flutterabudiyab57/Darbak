import 'package:dio/dio.dart';

import '../../../../core/constants/api_path.dart';
import '../../../../core/helpers/SharedPreference/pereferences.dart';

class ComplaintRepository {
  final Dio dio;

  ComplaintRepository(this.dio);

  Future<void> sendComplaint({
    required String name,
    required String phone,
    required String idNumber,
    required String description,
  }) async {
    String? token = await SharedPreferencesHelper().get("token");

    final data = {
      'name': name,
      'phone': phone,
      'id_number': idNumber,
      'description': description,
    };

    Map<String, dynamic> headers = token != null
        ? {
      'Authorization': 'Bearer $token',
    }
        : {};
    //
    // print("========== Complaint Request ==========");
    // print("URL => $complaints");
    // print("Headers => $headers");
    // print("Body => $data");
    // print("Token => $token");
    // print("=======================================");

    final response = await dio.post(
      complaints,
      data: data,
      options: Options(
        headers: headers,
      ),
    );

    // print("========== Complaint Response ==========");
    // print("Status Code => ${response.statusCode}");
    // print("Response Data => ${response.data}");
    // print("=======================================");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("فشل في الإرسال: ${response.statusCode}");
    }
  }
}