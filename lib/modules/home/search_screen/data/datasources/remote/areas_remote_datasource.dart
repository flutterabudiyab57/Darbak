import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:darbak/modules/home/search_screen/data/models/areas_model.dart';
import 'package:dio/dio.dart';

class AreasRemoteDatasource {
  final Dio _dio;

  AreasRemoteDatasource(this._dio);

  Future<List<AreasModel>> getAreas({int pageIndex = 1, int? regionId}) async {
    try {
      final Response response = await _dio.get(
          areas + "?region_id=$regionId",
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Accept-Language": langCode == '' ? "en" : langCode
            },
          ));
      final areasList = areasModelFromJson(response.data["data"] as List);
      return areasList;
    } on DioException catch (DioException) {
      throw Failure.fromDioError(DioException);
    } catch (error) {
      throw '..Oops $error';
    }
  }
}
