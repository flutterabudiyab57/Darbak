import 'package:dio/dio.dart';

import '../../../../../../core/constants/api_path.dart';
import '../../../../../../core/constants/langCode.dart';
import '../../../../../../core/helpers/SharedPreference/pereferences.dart';
import '../../models/all_coupons_model.dart';

class AllCouponService {
  final Dio dio;

  AllCouponService(this.dio);

  SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();

  Future<List<AllCouponsModel>> fetchAllCoupons() async {
    final token = await sharedPreferencesHelper.getToken();

    try {
      final response = await dio.get(
        allCouponsPath,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
            "Accept-Language": langCode.isEmpty ? "en" : langCode,
          },
        ),
      );
      print(response.data);

      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => AllCouponsModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch coupons: $e');
    }
  }
}
