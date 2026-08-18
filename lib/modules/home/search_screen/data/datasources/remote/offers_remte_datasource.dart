import 'dart:convert';
import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/SharedPreference/pereferences.dart';
import 'package:darbak/core/helpers/request_headers.dart';
import 'package:darbak/modules/home/search_screen/data/models/offers_model.dart';
import 'package:http/http.dart' as http;

class OffersRemotDataSource {
  static Future<List<OffersModel>> getOffers(String? languageCode) async {
    try {
      final SharedPreferencesHelper preferences = SharedPreferencesHelper();
      final token = await preferences.getToken();

      final response = await http.get(
        Uri.parse(mainApi + '/offers'),
        headers: RequestHeaders.forHttp(
          token: token,
          otherHeaders: {
            "Accept": "application/json",
            'Accept-Language': langCode == "" ? 'en' : langCode,
          },
        ),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          final List offersList = decoded['data'];


          final result =
          offersList.map((e) => OffersModel.fromJson(e)).toList();

          return result;
        } else {
          throw Exception("Unexpected JSON format");
        }
      } else {
        throw Exception("Error ${response.statusCode}");
      }
    } catch (error) {
      print('ERROR: $error');
      throw Exception(error);
    }
  }
}
