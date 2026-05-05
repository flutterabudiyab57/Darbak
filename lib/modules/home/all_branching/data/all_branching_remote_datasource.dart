import 'dart:convert';

import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:darbak/modules/home/all_branching/data/models/branch_model.dart';
import 'package:dio/dio.dart';

class AllBranchRemoteDataSource {
  final Dio dio = Dio();

  AllBranchRemoteDataSource(Dio dio);

  Future<Data> getBranches(
      {String languageCode = 'en', int? regionId}) async {
    try {
      final Response response = await dio.get(
        mainApi + '/branches?perPage=60',
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            "Accept": "application/json",
            "Accept-Language": langCode == "" ? "en" : langCode
          },
        ),
      );
      final dataBranch = json.decode(response.data);
      final Data branchModel = Data.fromMap(dataBranch);
      return branchModel;
    } on DioError catch (dioError) {
      throw Failure.fromDioError(dioError);
    } catch (error) {
      throw '..Oops $error';
    }
  }
}