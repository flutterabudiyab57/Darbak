import 'package:darbak/core/constants/api_path.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/langCode.dart';
import '../../../../core/helpers/SharedPreference/pereferences.dart';
import '../model/offer_model.dart';

class OffersService {
  final Dio _dio = Dio();

  SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();


  Future<List<dynamic>> fetchOffers() async {
    final token = await sharedPreferencesHelper.getToken();

    try {
      final response = await _dio.get(
        getOffers,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
            "Accept-Language": langCode.isEmpty ? "en" : langCode,
          },
        ),
      );
      return response.data['data'];
    } catch (e) {
      print("Error fetching offers: $e");
      return [];
    }
  }

  Future<OfferModel> fetchOfferDetails(int offerId) async {
    final response = await _dio.get(
      getOffers + "/$offerId",
      options: Options(
        headers: {
          "Accept": "application/json",
          "Accept-Language": langCode.isEmpty ? "en" : langCode,
        },
      ),
    );
   // print(response.data);

    if (response.statusCode == 200) {
      //print(response.data);
      return OfferModel.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to load offer details');
    }
  }
}
