import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:dio/dio.dart';

class FavouriteRemoteDatasource {
  final Dio dio;

  FavouriteRemoteDatasource(this.dio);

  addToFavourites(String? token,String carID) async {
    try {
      await dio.post(
        favourite + carID,
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
            "Accept-Language": langCode == '' ? "en" : langCode,
          },
        ),
      );
    } on DioError catch (dioError) {
      throw Failure.fromDioError(dioError);
    } catch (error) {
      throw '..Oops $error';
    }
  }
}
