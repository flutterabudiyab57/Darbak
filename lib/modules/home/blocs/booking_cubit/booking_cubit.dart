import 'package:darbak/modules/home/payment/data/models/coupon_model.dart';
import 'package:darbak/modules/home/payment/data/repositories/coupon_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final CouponRepository couponRepository;

  BookingCubit(this.couponRepository) : super(BookingInitial());

  String? selectedPaymentMethods;
  int? orderID;
  List<int>? additions;
  int? days = 0;
  String couponCode = "";
  String? receiveLocationId;

  void setPaymentMethods(String? method) {
    selectedPaymentMethods = method;
    emit(PaymentMethodChanged(selectedPaymentMethods));
  }

  void resetPaymentMethod() {
    selectedPaymentMethods = null;
    emit(PaymentMethodChanged(selectedPaymentMethods));
  }

  void applyCoupon(String code) {
    couponCode = code;
    checkCouponCode();
  }
  Future checkCouponCode() async {
    emit(CouponLoading());
    try {
      final coupon = await couponRepository.checkCoupon(
          code: couponCode, orderID: orderID.toString());

      if (coupon.success != null) {
        emit(CouponValid(coupon));

        if (coupon.paymentSettings != null &&
            coupon.paymentSettings!.isNotEmpty) {
          emit(PaymentMethodsUpdatedByCoupon(
            visaActive: coupon.visaActive,
            cashActive: coupon.cashActive,
            pointsActive: coupon.pointsActive,
            madfouActive: coupon.madfouActive,
            tamaraActive: coupon.tamaraActive,
            appleActive: coupon.appleActive,
            mispayActive: coupon.mispayActive,
          ));
        }
      } else {
        emit(CouponInvalid("Coupon Not Valid"));
      }
    } catch (e) {
      emit(CouponInvalid(e.toString()));
    }
  }

  Future deleteCouponCode() async {
    emit(CouponLoading());
    try {
      final coupon = await couponRepository.deleteCoupon(
          orderID: orderID.toString());

      if (coupon.success != null) {
        emit(DeleteCoupon(coupon));
        emit(PaymentMethodsRestoredAfterDeleteCoupon());
      } else {
        emit(DeleteCouponInvalid("Coupon Not Deleted"));
      }
    } catch (e) {
      emit(DeleteCouponInvalid(e.toString()));
    }
  }

  reset() {
    selectedPaymentMethods = null;
    orderID = 0;
    additions = [];
    days = 0;
    couponCode = "";
  }
}
