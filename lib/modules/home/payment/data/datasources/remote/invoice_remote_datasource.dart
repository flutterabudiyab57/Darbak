import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:darbak/modules/home/payment/data/models/automated_invoice_model.dart';
import 'package:darbak/modules/home/payment/data/models/invoice_model.dart';
import 'package:dio/dio.dart';


class InvoiceRemoteDatasource {
  final Dio _dio = Dio();

  Future<InvoiceModel> getInvoice({
    String? languageCode,
    required String token,
    required String orderID,
    required List<int> additions,
    String? paymentType
  }) async {
    try {
      final Response response = await _dio.post(
        invoicePath,
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
            "Accept-Language": langCode == '' ? "en" : langCode
          },
        ),
        data: {'order_id': orderID, 'features': additions,'payment_type':paymentType.toString()},
      );
      ///-------------
      print(paymentType.toString());
      return invoiceModelFromJson(response.data);
    } on DioException catch (DioException) {
      throw Failure.fromDioError(DioException);
    } catch (error) {
      throw '..Oops $error';
    }
  }

  Future<AutomatedInvoiceModel> getAutomatedInvoice({
    String? languageCode,
    required String token,
    required String orderID,
    required List<int> additions,
  }) async {
    try {
      final Response response = await _dio.post(
        invoiceAutomationPath,
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
            "Accept-Language": langCode == '' ? "en" : langCode
          },
        ),
        data: {
          'order_id': orderID,
          'features': additions,
          "contract_id": orderID
        },
      );
      return automatedInvoiceModelFromJson(response.data);
    } on DioException catch (DioException) {
      throw Failure.fromDioError(DioException);
    } catch (error) {
      throw '..Oops $error';
    }
  }
}
