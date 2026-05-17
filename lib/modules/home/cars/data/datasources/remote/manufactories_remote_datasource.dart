import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:darbak/modules/home/cars/data/models/manufactories_Model.dart';
import 'package:dio/dio.dart';

class ManufactoriesRemoteDataSource {
  final Dio _dio = Dio();

  Future<Manufactories> getManufactories() async {
    try {
      final Response response = await _dio.get(
        manufactories,
        options: Options(responseType: ResponseType.plain, headers: {
          "Accept": "application/json",
          "Accept-Language": langCode == '' ? "en" : langCode
        }),
      );
      final manuData = manufactoriesFromMap(response.data);
      return manuData;
    } on DioException catch (DioException) {
      throw Failure.fromDioError(DioException);
    } catch (error) {
      throw '..Oops $error';
    }
  }
}
