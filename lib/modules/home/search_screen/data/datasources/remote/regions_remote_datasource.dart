import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:darbak/modules/home/search_screen/data/models/regions_model.dart';
import 'package:dio/dio.dart';

class RegionsRemoteDatasource {
  final Dio _dio;

  RegionsRemoteDatasource(this._dio);

  Future<List<RegionModel>?> getRegions() async {
    try {
      final Response response = await _dio.get(regions,
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Accept-Language": langCode.isEmpty ? "en" : langCode,
            },
          ));
      final regionsModel = regionModelFromJson(response.data["data"]as List);
      return regionsModel;
    } on DioError catch (dioError) {
      throw Failure.fromDioError(dioError);
    } catch (error) {
      throw '..Oops $error';
    }
  }
}
