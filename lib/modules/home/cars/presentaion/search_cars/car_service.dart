import 'package:dio/dio.dart';
import '../../../../../core/constants/api_path.dart';
import '../../../../../core/constants/langCode.dart';
import '../../data/models/cars_model.dart';

class CarService {
  final Dio _dio = Dio();

  Future<List<DataCars>> searchCars(String searchTerm) async {
    final url = "${mainApi}/cars/?trem=$searchTerm";

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Accept-Language": langCode.isEmpty ? "en" : langCode,
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          final List carsData = responseData['data'];
          return carsData.map((data) => DataCars.fromMap(data)).toList();
        } else {
          throw Exception('Error: "data" field not found in response.');
        }
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error searching cars: $error');
    }
  }
}
