
import 'package:darbak/core/helpers/SharedPreference/pereferences.dart';
import 'package:darbak/modules/home/additions/data/models/payment_step_model.dart';
import 'package:darbak/modules/home/payment/data/datasources/remote/payment_remote_datasource.dart';
import 'package:darbak/modules/home/payment/data/models/credit_card_model.dart';

class PaymentRepository {
  final PaymentRemoteDatasource paymentRemoteDatasource;
  final SharedPreferencesHelper preferencesHelper;

  PaymentRepository(this.paymentRemoteDatasource, this.preferencesHelper);

  Future<PaymentStepModel> activePaymentStep({
    required CreditCardModel? cardModel,
  }) async {
    final userToken = await preferencesHelper.getToken() ?? "";
    // print("pay0 orderId ${cardModel?.orderId.toString()}");
    // print("pay0 cardNumber ${cardModel?.cardNumber  .toString()}");

    try {
      final response = await paymentRemoteDatasource.activePaymentStep(
        token: userToken,
        cardModel: cardModel,
      );



      return response;
    } catch (error) {
      // print("pay1 userToken $userToken");
      // print("pay1 cardModel $cardModel");
      // print("'activePaymentStep: $error");
      // print("pay1 cardModel ${cardModel?.toString()}");

      throw 'Payment step failed: $error';
    }
  }


  Future<PaymentStepModel> activeAutomatedPaymentStep(
      {required CreditCardModel? cardModel}) async {
    try {
      final userToken = await preferencesHelper.getToken() ?? "";
      final response = await paymentRemoteDatasource.activeAutomatedPaymentStep(
          token: userToken, cardModel: cardModel);
      return response;
    } catch (error) {

      // print(" activeAutomatedPaymentStep :$error");

      throw '..Oops $error';
    }
  }

  Future<bool> checkOrder({required int orderId}) async {
    try {
      final userToken = await preferencesHelper.getToken() ?? "";
      final response = await paymentRemoteDatasource.checkOrderStatus(
          token: userToken,
          orderId: orderId);
      print("Hammad29");
      return response;
    } catch (error) {

      print(" checkOrder :$error");
      throw error;
    }
  }

}
