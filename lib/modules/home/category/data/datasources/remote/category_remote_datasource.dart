import 'dart:convert';

import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:darbak/modules/home/category/data/models/category_model.dart';
import 'package:dio/dio.dart';

class CategoryRemotDataSource {
  static Dio? _dio = Dio();
  Future<CategoryModelData> getCategory() async {
    try {
      final Response response = await _dio!.get(
        mainApi + category,
        options: Options(responseType: ResponseType.plain, headers: {
          "Accept": "application/json",
          "Accept-Language": langCode == '' ? "en" : langCode
        }),
      );
      final list = json.decode(response.data);
      CategoryModelData categoryModelData = CategoryModelData.fromJson(list);

      return categoryModelData;
    } on DioException catch (DioException) {
      throw Failure.fromDioError(DioException);
    } catch (error) {
      throw '..Oops $error';
    }
  }
}
