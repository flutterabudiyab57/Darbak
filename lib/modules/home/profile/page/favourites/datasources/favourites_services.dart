import 'dart:convert';

import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/SharedPreference/pereferences.dart';
import 'package:http/http.dart' as http;

import '../../../../cars/data/models/cars_model.dart';

class FavouritesService {
  static Future<List<DataCars>> getFavourites({String? languageCode}) async {
    final SharedPreferencesHelper preferences = SharedPreferencesHelper();
    final token = await preferences.getToken();
    var responce = await http.get(Uri.parse(mainApi + '/profile'), headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      'x-accept-language': langCode == "" ? 'en' : langCode
    });
    var data = json.decode(responce.body) as Map<String, dynamic>;

    if (responce.statusCode == 200) {
      final favouriteData = data['data']['favorite'] as List;
      final List<DataCars> favourites = <DataCars>[];
      favouriteData.forEach((element) {
        favourites.add(DataCars.fromMap(element));
      });
      return favourites;
    } else if (responce.statusCode == 401) {
      throw Exception(data['message']);
    } else {
      return throw Exception();
    }
  }
}
