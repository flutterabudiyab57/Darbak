import 'dart:convert';

import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/modules/home/all_branching/data/models/branch_model.dart';
import 'package:http/http.dart' as http;
class BranchesService {
  static Future<List<BranchModel>> getBranches({
    String languageCode = 'en',
    int pageIndex = 1,
    int? regionId,
    int perPage = 60,
  }) async {
    final queryParams = {
      "home_delivery": "0",
      "page": pageIndex.toString(),
      "regions": regionId?.toString(),
      "perPage": perPage.toString(),
    };

    final uri = Uri.parse(mainApi + '/branches').replace(queryParameters: queryParams);
    var response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Accept-Language": langCode.isEmpty ? "en" : langCode,
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body) as Map<String, dynamic>;
      List list = data['data'] as List;
      List<BranchModel> list2 = list.map((item) => BranchModel.fromMap(item)).toList();
      return list2;
    } else {
      print(response.statusCode);
      throw Exception(response.body);
    }
  }
  static Future<List<BranchModel>> getDeliveryBranches() async {
    var response = await http.get(
      Uri.parse(mainApi + '/branches?home_delivery=1'),
      headers: {
        "Content-Type": "application/json",
        "Accept-Language": langCode == '' ? "en" : langCode
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body) as Map<String, dynamic>;
      List list = data['data'] as List;
      List<BranchModel> list2 = [];
      for (var item in list) {
        list2.add(BranchModel.fromMap(item));
      }

     print("list2: Delivery Branches: $list2" );
      return list2;
    } else {
      print(response.statusCode);
      throw Exception(response.body);
    }
  }
  static Future<List<BranchModel>> getAirportBranches() async {
    var response = await http.get(
      Uri.parse(mainApi + '/branches?airport=1'),
      headers: {
        "Content-Type": "application/json",
        "Accept-Language": langCode == '' ? "en" : langCode
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body) as Map<String, dynamic>;
      List list = data['data'] as List;
      List<BranchModel> list2 = [];
      for (var item in list) {
        list2.add(BranchModel.fromMap(item));
      }

      return list2;
    } else {
      print(response.statusCode);
      throw Exception(response.body);
    }
  }
}
