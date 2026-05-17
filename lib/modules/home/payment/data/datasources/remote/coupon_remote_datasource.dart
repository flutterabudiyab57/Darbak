import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:darbak/modules/home/payment/data/models/coupon_model.dart';
import 'package:dio/dio.dart';

class CouponRemoteDatasource {
  final Dio _dio;

  CouponRemoteDatasource(this._dio);

  Future<CouponModel> checkCoupon({
    required String token,
    required String orderID,
    required String code,
  }) async {
    try {
      final Response response = await _dio.post(
        couponPath,
        options: Options(
          responseType: ResponseType.json,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
        data: {
          "order_id": orderID,
          "coupon": code,
        },
      );
      return CouponModel.fromJson(response.data);
    } on DioException catch (dioError) {
      throw Failure.fromDioError(dioError);
    } catch (error) {
      throw '..Oops $error';
    }
  }

  Future<CouponModel> deleteCoupon({
    required String token,
    required String orderID,
  }) async {
    try {
      final Response response = await _dio.post(
        deleteCouponPath,
        options: Options(
          responseType: ResponseType.json,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
        data: {
          "order_id": orderID,
        },
      );
      return CouponModel.fromJson(response.data); // âœ…
    } on DioException catch (dioError) {
      throw Failure.fromDioError(dioError);
    } catch (error) {
      throw '..Oops $error';
    }
  }


}
