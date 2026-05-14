part of 'booking_cubit.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object> get props => [];
}

class BookingInitial extends BookingState {}

class PaymentMethodChanged extends BookingState {
  final PaymentMethod? method;

  PaymentMethodChanged(this.method);

  @override
  List<Object> get props => [method?.wire ?? ""];
}

class CouponLoading extends BookingState {}

class CouponValid extends BookingState {
  final CouponModel couponModel;

  CouponValid(this.couponModel);

  @override
  List<Object> get props => [couponModel];
}

class CouponInvalid extends BookingState {
  final String? message;

  CouponInvalid(this.message);

  @override
  List<Object> get props => [message ?? ""];
}

class DeleteCoupon extends BookingState {
  final CouponModel couponModel;

  DeleteCoupon(this.couponModel);

  @override
  List<Object> get props => [couponModel];
}

class DeleteCouponInvalid extends BookingState {
  final String? message;

  DeleteCouponInvalid(this.message);

  @override
  List<Object> get props => [message ?? ""];
}
class PaymentMethodsUpdatedByCoupon extends BookingState {
  final bool visaActive;
  final bool cashActive;
  final bool pointsActive;
  final bool madfouActive;
  final bool tamaraActive;
  final bool appleActive;
  final bool mispayActive;

  const PaymentMethodsUpdatedByCoupon({
    required this.visaActive,
    required this.cashActive,
    required this.pointsActive,
    required this.madfouActive,
    required this.tamaraActive,
    required this.appleActive,
    required this.mispayActive,
  });

  @override
  List<Object> get props => [
    visaActive,
    cashActive,
    pointsActive,
    madfouActive,
    tamaraActive,
    appleActive,
    mispayActive,
  ];
}

class PaymentMethodsRestoredAfterDeleteCoupon extends BookingState {}