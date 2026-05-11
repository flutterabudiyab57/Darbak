import 'dart:convert';
import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/SharedPreference/pereferences.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:darbak/modules/home/cars/data/models/cars_model.dart';
import 'package:dio/dio.dart';
class CarsRemoteDataSource {
  final Dio _dio;
  final SharedPreferencesHelper sharedPreferencesHelper;
  CarsRemoteDataSource(this._dio, this.sharedPreferencesHelper);
  Future<Cars> getAllCars(
      int pageNumber, {
        int? branchId,
        List<String>? categoryIds,
        List<String>? manufactoryIds,
        int? minPrice,
        int? maxPrice,
        int? model,
      }) async {

    try {

      final token = await sharedPreferencesHelper.getToken();
      final url = branchId == null
          ? mainApi + allCars + "?page=$pageNumber"
          : mainApi + carsByBranch + "$branchId" + carsByPages2 + "$pageNumber";

      final Response response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
            "Accept-Language": langCode.isEmpty ? "en" : langCode,
          },
        ),
      );


      final dataCars = json.decode(response.data) as Map<String, dynamic>;
      final Cars cars = Cars.fromMap(dataCars);

      if (response.statusCode == 200) {
        print("Data fetched successfully.");
      } else {
        print("Unexpected status code: ${response.statusCode}");
      }

      return cars;
    } on DioError catch (dioError) {
      print("Dio error occurred: ${dioError.response?.data}");
      print("Error message: ${dioError.message}");
      throw Failure.fromDioError(dioError);
    } catch (error) {
      print("Unexpected error: $error");
      throw Exception('..Oops $error');
    }
  }

  Future<Cars> getCarsByFilter({
    required int pageNumber,
    List<String>? categoryIds,
    List<String>? manufactoryIds,
    List<String>? model,
    int? minPrice,
    int? maxPrice,
  }) async {
    try {
      // final token = await sharedPreferencesHelper.getToken();
      final String? catIds = _generateCategorySearchParameters(categoryIds ?? []);
      final String? brandIds = _generateBrandSearchParameters(manufactoryIds ?? []);
      final String? modelYears = _generateModelSearchParameters(model ?? []);

      // print('Ashraf' + brandIds.toString());
      final Response response = await _dio.get(
        mainApi +
            allCars +
            "?$catIds&$brandIds&$modelYears&minimum=$minPrice&maximum=$maxPrice&page=$pageNumber",
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            "Accept": "application/json",
            //"Authorization": "Bearer $token",
            "Accept-Language": langCode == "" ? "en" : langCode
          },
        ),
      );
      final dataCars = json.decode(response.data) as Map<String, dynamic>;
      final Cars cars = Cars.fromMap(dataCars);
      return cars;
    } on DioError catch (dioError) {
      throw Failure.fromDioError(dioError);
    } catch (error) {
      throw '..Oops $error';
    }
  }

  /// New method to fetch cars by search query
  Future<Cars> getCarsBySearch({required String searchQuery}) async {
    try {
      final String url = 'https://abudiyab-soft.com/cars/api?trem=$searchQuery';
      print("Fetching cars with search URL: $url");

      final Response response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            "Accept": "application/json",
            "Accept-Language": langCode.isEmpty ? "en" : langCode,
          },
        ),
      );

      print("Response data: ${response.data}");

      final dataCars = json.decode(response.data) as Map<String, dynamic>;
      final Cars cars = Cars.fromMap(dataCars);

      if (response.statusCode == 200) {
        print("Data fetched successfully1.");
      } else {
        print("Unexpected status code: ${response.statusCode}");
      }

      return cars;
    } on DioError catch (dioError) {
      print("Dio error occurred: ${dioError.response?.data}");
      print("Error message: ${dioError.message}");
      throw Failure.fromDioError(dioError);
    } catch (error) {
      print("Unexpected error: $error");
      throw Exception('..Oops $error');
    }
  }

  String _generateCategorySearchParameters(List<String> categoryIds) {
    if (categoryIds.isNotEmpty) {
      final cats = categoryIds.map((e) => "category_ids[]=$e&").toList();
      cats.last = cats.last.substring(0, cats.last.length - 1);
      var catsData = cats.toString().replaceFirst("[", "");
      catsData = catsData
          .toString()
          .substring(0, catsData.length - 1)
          .replaceAll(" ", "")
          .replaceAll(",", "");
      return catsData.toString();
    }
    return "";
  }

  String? _generateBrandSearchParameters(List<String> brandIds) {
    if (brandIds.isNotEmpty) {
      final brands = brandIds.map((e) => "manufactory_ids[]=$e&").toList();
      brands.last = brands.last.substring(0, brands.last.length - 1);
      var brandData = brands.toString().replaceFirst("[", "");
      brandData = brandData
          .toString()
          .substring(0, brandData.length - 1)
          .replaceAll(" ", "")
          .replaceAll(",", "");
      // print ("Hammad" +  brandData.toString());
      return brandData;
    }
    return "";
  }

  ///--------------------------------
  String _generateModelSearchParameters(List<String> modelYears) {
    if (modelYears.isNotEmpty) {
      final cats = modelYears.map((e) => "model_years[]=$e&").toList();
      cats.last = cats.last.substring(0, cats.last.length - 1);
      var catsData = cats.toString().replaceFirst("[", "");
      catsData = catsData
          .toString()
          .substring(0, catsData.length - 1)
          .replaceAll(" ", "")
          .replaceAll(",", "");
      return catsData.toString();
    }
    return "";
  }
}
