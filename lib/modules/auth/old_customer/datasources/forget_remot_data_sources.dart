// import 'dart:convert';
//
// import 'package:darbak/core/constants/api_path.dart';
// import 'package:darbak/core/constants/langCode.dart';
// import 'package:darbak/core/helpers/exception/exceptions.dart';
// import 'package:dio/dio.dart';
//
// class ForgetRemotDataSources {
//   final Dio dio = Dio();
//   Future<String> forgetOldCustomer(
//       {required String phone, required String id}) async {
//     try {
//       final Response response = await dio.post(enterInfoOldCustomer,
//           options: Options(
//             responseType: ResponseType.plain,
//             headers: {
//               "Accept": "application/json",
//               "Accept-Language": langCode == "" ? "en" : langCode
//             },
//           ),
//           data: {
//             "phone_number": phone,
//             "id_number": id,
//           });
//       var data = json.decode(response.data);
//       return data['token'];
//     } on DioException catch (DioException) {
//       throw Failure.fromDioError(DioException);
//     } catch (error) {
//       throw '..Oops $error';
//     }
//   }
// }
