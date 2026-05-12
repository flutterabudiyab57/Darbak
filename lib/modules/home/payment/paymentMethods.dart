import 'package:bounce/bounce.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/modules/home/payment/widget/copouns_bottom_sheet.dart';
import 'package:darbak/modules/home/payment/widget/coupon_tile.dart';
import 'package:darbak/modules/home/payment/widget/invoice_bottom_sheet.dart';
import 'package:dio/dio.dart';
// import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../core/constants/assets/app_colors.dart';
import '../../../core/constants/assets/assets.dart';
import '../../../core/constants/langCode.dart';
import '../../../core/helpers/helper_fun.dart';
import '../../../language/locale.dart';
import '../../widgets/components/ad_gradient_btn.dart';
import '../additions/data/models/step_one_order_model.dart' hide Icon;
import '../additions/presentaion/blocs/addition_cubit/additions_cubit.dart';
import '../blocs/booking_cubit/booking_cubit.dart';
import '../cars/data/models/cars_model.dart';
import '../cash_back/bloc/cashback__cubit.dart';
import '../cash_back/screen/widgets/Cashback_Balance.dart';
import '../profile/page/privacy_policy/privacy_policy.dart';
import 'blocs/invoice_cubit.dart';
import 'data/datasources/remote/all_coupons_service.dart';
import 'data/models/credit_card_model.dart';
import 'invoice.dart';
import 'invouce_notCompleted.dart';
import 'widget/payment_card.dart';
import 'widget/title_widget.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final bool newBooking;
  final DataCars? carModel;
  final StepOneOrderModel? stepOneOrderModel;
  final bool isAutomated;
  final bool? isNotCompleted;
  final DataCars? datum;
  final String? orderId;
  final CreditCardModel? cardModel;

  PaymentMethodsScreen(
    this.newBooking, {
    required this.stepOneOrderModel,
    required this.carModel,
    this.isAutomated = false,
    this.datum,
    this.isNotCompleted,
    this.orderId,
    this.cardModel,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool _isAgreeTerms = false;
  bool? see = true;
  bool? _couponVisaActive;
  bool? _couponCashActive;
  bool? _couponPointsActive;
  bool? _couponMadfouActive;
  bool? _couponTamaraActive;
  bool? _couponAppleActive;
  bool? _couponMispayActive;
  bool _isOpeningCoupons = false;

  bool _isActive(bool? couponValue, bool? originalValue) {
    return couponValue ?? originalValue ?? false;
  }

  bool get _origVisa => widget.stepOneOrderModel == null
      ? BlocProvider.of<AdditionsCubit>(context).stepModel?.order?.visaActive ??
          false
      : widget.stepOneOrderModel!.visaActive ?? false;

  bool get _origCash => widget.stepOneOrderModel == null
      ? BlocProvider.of<AdditionsCubit>(context).stepModel?.order?.cashActive ??
          false
      : widget.stepOneOrderModel!.cashActive ?? false;

  bool get _origPoints => widget.stepOneOrderModel == null
      ? BlocProvider.of<AdditionsCubit>(context)
              .stepModel
              ?.order
              ?.pointsActive ??
          false
      : widget.stepOneOrderModel!.pointsActive ?? false;

  bool get _origMadfou => widget.stepOneOrderModel == null
      ? BlocProvider.of<AdditionsCubit>(context)
              .stepModel
              ?.order
              ?.madfouActive ??
          false
      : widget.stepOneOrderModel!.madfouActive ?? false;

  bool get _origTamara => widget.stepOneOrderModel == null
      ? BlocProvider.of<AdditionsCubit>(context)
              .stepModel
              ?.order
              ?.tamaraActive ??
          false
      : widget.stepOneOrderModel!.tamaraActive ?? false;

  @override
  void initState() {
    super.initState();

    final bookingCubit = BlocProvider.of<BookingCubit>(context);
    bookingCubit.resetPaymentMethod();

    final additionsCubit = BlocProvider.of<AdditionsCubit>(context);
    Feature? featureToRemove;
    if (featureToRemove != null) {
      additionsCubit.removeAddition(context, featureToRemove);
    }

    BlocProvider.of<InvoiceCubit>(context).getInvoice(context);
    BlocProvider.of<CashbackCubit>(context).getCashbackBalance();
  }

  final AllCouponService couponService;

  _PaymentMethodsScreenState() : couponService = AllCouponService(Dio());

  Future<void> _showCoupons(BuildContext context) async {
    try {
      final coupons = await couponService.fetchAllCoupons();

      await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        backgroundColor: backgroundColor(context),
        constraints: const BoxConstraints(
          maxWidth: double.infinity,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
            topEnd: Radius.circular(25.r),
            topStart: Radius.circular(25.r),
          ),
        ),
        builder: (context) => CouponBottomSheet(coupons: coupons),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.errorFetchingCoupons}: $e')),
      );
    }
  }

  double _getExpectedCashbackAmount() {
    if (widget.stepOneOrderModel?.cashback?.expectedCashbackAmount != null) {
      return widget.stepOneOrderModel!.cashback!.expectedCashbackAmount!;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<BookingCubit, BookingState>(
                  buildWhen: (previous, current) =>
                      current is PaymentMethodChanged ||
                      current is PaymentMethodsUpdatedByCoupon ||
                      current is PaymentMethodsRestoredAfterDeleteCoupon,
                  builder: (context, state) {
                    if (state is PaymentMethodsUpdatedByCoupon) {
                      _couponVisaActive = state.visaActive;
                      _couponCashActive = state.cashActive;
                      _couponPointsActive = state.pointsActive;
                      _couponMadfouActive = state.madfouActive;
                      _couponTamaraActive = state.tamaraActive;
                      _couponAppleActive = state.appleActive;
                      _couponMispayActive = state.mispayActive;
                    }
                    if (state is PaymentMethodsRestoredAfterDeleteCoupon) {
                      _couponVisaActive = null;
                      _couponCashActive = null;
                      _couponPointsActive = null;
                      _couponMadfouActive = null;
                      _couponTamaraActive = null;
                      _couponAppleActive = null;
                      _couponMispayActive = null;
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          Assets.icon_coupon,
                                          height: 16.h,
                                          width: 20.w,
                                        ),
                                        SizedBox(width: 7.w),
                                        Text(
                                          locale.isDirectionRTL(context)
                                              ? "كوبون الخصم"
                                              : "Discount coupon",
                                          style: AppTypography
                                              .mainTypographyColor18(context),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        if (_isOpeningCoupons) return;

                                        _isOpeningCoupons = true;

                                        await _showCoupons(context);

                                        _isOpeningCoupons = false;
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 7.w, vertical: 8.h),
                                        decoration: ShapeDecoration(
                                          color: backgroundColor(context),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1.w,
                                              color: strokeGrayColor(context),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(25.r),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(width: 5.w),
                                            Text(
                                              locale.isDirectionRTL(context)
                                                  ? "عرض الكوبونات المتاحة"
                                                  : "View available coupons",
                                              style: AppTypography
                                                  .mainTypographyColor14(
                                                      context),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 12.hs(context),
                              ),
                              CouponTile(),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15.hs(context),
                        ),
                        BlocBuilder<CashbackCubit, CashbackState>(
                          builder: (context, cashbackState) {
                            double availableBalance = 0;

                            if (cashbackState is CashbackDataState &&
                                cashbackState.cashbackBalance != null) {
                              availableBalance = cashbackState.cashbackBalance!
                                  .data.summary.available.total;
                            }
                            final expectedCashback =
                                _getExpectedCashbackAmount();
                            return DaraksonBalanceWidget(
                              availableBalance: availableBalance,
                              pendingCredit: expectedCashback,
                              isEnabled: false,
                              orderId: widget.stepOneOrderModel!.order!.id
                                  .toString(),
                              onToggle: (isEnabled) {
                                print('Balance toggle: $isEnabled');
                              },
                            );
                          },
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Container(
                            decoration: BoxDecoration(
                              color: buttonWhiteColor(context),
                              border: Border.all(
                                  width: 1.5.w,
                                  color: strokeGrayColor(context)),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 6.h),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 6.w),
                                  child: PageTitle(),
                                ),
                                SizedBox(height: 2.h),
                                if (_isActive(_couponVisaActive, _origVisa))
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      PaymentMethodCard(
                                        text: locale.visa.toString(),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        svg: Assets.icon_credit_card,
                                      ),
                                    ],
                                  ),
                                if (_isActive(_couponCashActive, _origCash))
                                  PaymentMethodCard(
                                    text: locale.cash.toString(),
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    svg: Assets.icon_money,
                                  ),
                                if (_isActive(_couponPointsActive, _origPoints))
                                  PaymentMethodCard(
                                    text: locale.points.toString(),
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    svg: Assets.icon_points,
                                  ),
                                if (_isActive(_couponMadfouActive, _origMadfou))
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      PaymentMethodCard(
                                        text: locale.isDirectionRTL(context)
                                            ? "مدفوع"
                                            : "madfou",
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        svg: "assets/icons/madfu_ar_logo.svg",
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14.w),
                                        child: Text(
                                          locale.isDirectionRTL(context)
                                              ? "قسم فاتورتك حتى 4 أقساط بسهولة وأمان مع مدفوع."
                                              : "Split in up to 4 payments with Madfou.",
                                          style: AppTypography.paragraphColor14(
                                              context),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_isActive(_couponTamaraActive, _origTamara))
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      PaymentMethodCard(
                                        text: locale.isDirectionRTL(context)
                                            ? "تمارا"
                                            : "tamara",
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        svg: "assets/icons/tamara.svg",
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14.w),
                                        child: Text(
                                          locale.isDirectionRTL(context)
                                              ? "ادفع جزء من المبلغ الحين والباقي علي دفعات حسب خطة الدفع."
                                              : "Pay part of the costs and Split payments according to the payment plan.",
                                          style: AppTypography.paragraphColor14(
                                              context),
                                        ),
                                      ),
                                    ],
                                  ),
                                SizedBox(height: 8.h),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isAgreeTerms = !_isAgreeTerms;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 26.w,
                                  height: 26.h,
                                  decoration: BoxDecoration(
                                    color: _isAgreeTerms
                                        ? buttonPrimaryBgColor(context)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      width: 1.5.w,
                                      color: _isAgreeTerms
                                          ? buttonPrimaryBgColor(context)
                                          : strokeGrayColor(context),
                                    ),
                                  ),
                                  child: _isAgreeTerms
                                      ? Icon(
                                          Icons.check,
                                          size: 18.sp,
                                    color: Colors.white,
                                        )
                                      : null,
                                ),
                                SizedBox(width: 10.w),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              PrivacyPolicyScreen()),
                                    );
                                  },
                                  child: Text(
                                    locale.agreeTerms.toString(),
                                    textAlign: TextAlign.right,
                                    style: AppTypography.mainTypographyColor16(
                                        context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
          widget.newBooking
              ? Align(
                  alignment: locale.isDirectionRTL(context)
                      ? Alignment.bottomLeft
                      : Alignment.bottomRight,
                  child: BlocConsumer<AdditionsCubit, AdditionsState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      return state is CheckOrderStateLoading ||
                              state is InvoiceLoading
                          ? Center(
                              child: Lottie.asset(
                                "assets/anim/loading_anim.json",
                                width: 100.w,
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: GestureDetector(
                                      onTap: () async {
                                        // final facebookAppEvents =
                                        //     FacebookAppEvents();
                                        // await facebookAppEvents
                                        //     .logInitiatedCheckout();
                                        // await facebookAppEvents.flush();
                                        // print('logInitiatedCheckout');
                                        if (BlocProvider.of<BookingCubit>(
                                                        context)
                                                    .selectedPaymentMethods !=
                                                null &&
                                            _isAgreeTerms) {
                                          context
                                                  .read<BookingCubit>()
                                                  .additions =
                                              context
                                                  .read<AdditionsCubit>()
                                                  .additions;
                                          if (BlocProvider.of<BookingCubit>(
                                                      context)
                                                  .selectedPaymentMethods !=
                                              locale.visa.toString()) {
                                            if (widget.isNotCompleted == true) {
                                              context
                                                  .read<AdditionsCubit>()
                                                  .stepModel!
                                                  .order!
                                                  .additions
                                                  .toString()
                                                  .isEmpty;
                                              await BlocProvider.of<
                                                      InvoiceCubit>(context)
                                                  .getInvoiceNotCompletedOrder(
                                                      context,
                                                      widget.orderId
                                                          .toString());
                                              await context
                                                  .read<AdditionsCubit>()
                                                  .checkOrderStep(
                                                      orderId: widget.orderId);
                                              PersistentNavBarNavigator
                                                  .pushNewScreen(
                                                context,
                                                withNavBar: false,
                                                screen: InvoiceNotCompletedUI(
                                                  carModel: widget.carModel,
                                                  orderID:
                                                      widget.orderId.toString(),
                                                  isNotCompletedOrder:
                                                      widget.isNotCompleted ==
                                                              true
                                                          ? true
                                                          : false,
                                                ),
                                              );
                                            } else {
                                              PersistentNavBarNavigator
                                                  .pushNewScreen(
                                                context,
                                                withNavBar: false,
                                                screen: InvoiceUI(
                                                  carModel: widget.carModel,
                                                  orderID:
                                                      widget.orderId.toString(),
                                                  isNotCompletedOrder:
                                                      widget.isNotCompleted ==
                                                              true
                                                          ? true
                                                          : false,
                                                ),
                                              );
                                            }
                                          } else if (BlocProvider.of<
                                                      BookingCubit>(context)
                                                  .selectedPaymentMethods ==
                                              locale.visa.toString()) {
                                            if (isVisa == null ||
                                                isVisa == false) {
                                              HelperFunctions.dialog(
                                                context: context,
                                                title: locale.error.toString(),
                                                body: locale
                                                        .isDirectionRTL(context)
                                                    ? "من فضلك تاكد من بيانات البطاقه المدخله."
                                                    : "Please check the entered card details.",
                                              );
                                              print(
                                                  "fdgdfgg: ${BlocProvider.of<BookingCubit>(context).selectedPaymentMethods}");
                                            } else {
                                              if (widget.isNotCompleted ==
                                                  true) {
                                                PersistentNavBarNavigator
                                                    .pushNewScreen(
                                                  context,
                                                  withNavBar: false,
                                                  screen: InvoiceNotCompletedUI(
                                                    carModel: widget.carModel,
                                                    orderID: widget.orderId
                                                        .toString(),
                                                    isNotCompletedOrder:
                                                        widget.isNotCompleted ==
                                                                true
                                                            ? true
                                                            : false,
                                                  ),
                                                );
                                              } else {
                                                PersistentNavBarNavigator
                                                    .pushNewScreen(
                                                  context,
                                                  withNavBar: false,
                                                  screen: InvoiceUI(
                                                    carModel: widget.carModel,
                                                    orderID: widget.orderId
                                                        .toString(),
                                                    isNotCompletedOrder:
                                                        widget.isNotCompleted ==
                                                                true
                                                            ? true
                                                            : false,
                                                  ),
                                                );

                                                print(
                                                    "bg1: ${BlocProvider.of<BookingCubit>(context).selectedPaymentMethods}");
                                                print(
                                                    "bg0+1: ${widget.orderId.toString()}");
                                              }
                                            }
                                          }

                                          /// --------- Madfu Pay ---------
                                          else if (BlocProvider.of<
                                                      BookingCubit>(context)
                                                  .selectedPaymentMethods ==
                                              (locale.isDirectionRTL(context)
                                                  ? "مدفوع"
                                                  : "madfou")) {
                                            if (widget.isNotCompleted == true) {
                                              PersistentNavBarNavigator
                                                  .pushNewScreen(
                                                context,
                                                withNavBar: false,
                                                screen: InvoiceNotCompletedUI(
                                                  carModel: widget.carModel,
                                                  orderID:
                                                      widget.orderId.toString(),
                                                  isNotCompletedOrder:
                                                      widget.isNotCompleted ==
                                                              true
                                                          ? true
                                                          : false,
                                                ),
                                              );
                                            } else {
                                              PersistentNavBarNavigator
                                                  .pushNewScreen(
                                                context,
                                                withNavBar: false,
                                                screen: InvoiceUI(
                                                  carModel: widget.carModel,
                                                  orderID:
                                                      widget.orderId.toString(),
                                                  isNotCompletedOrder:
                                                      widget.isNotCompleted ==
                                                              true
                                                          ? true
                                                          : false,
                                                ),
                                              );

                                              print(
                                                  "Madfu: ${BlocProvider.of<BookingCubit>(context).selectedPaymentMethods}");
                                              print(
                                                  "Madfu: ${widget.orderId.toString()}");
                                            }
                                          }
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: locale.noMethodSelected
                                                .toString(),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Color(0xffF6A9A9),
                                            textColor: Colors.red,
                                            fontSize: 14.sp,
                                          );
                                        }
                                      },
                                      child: ADGradientButton(
                                        locale.goToPayment.toString(),
                                        textStyle:
                                            AppTypography.buttonText18(context),
                                        icon: Icons.payment_rounded,
                                        iconSize: 24.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15.w,
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Bounce(
                                      onTap: () {
                                        final invoiceCubit =
                                            BlocProvider.of<InvoiceCubit>(
                                                context);
                                        if (invoiceCubit.data == null) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Invoice data is not available.", textColor: Colors.red,
                                            fontSize: 14.sp,);

                                          return;
                                        }

                                        showModalBottomSheet(
                                          isScrollControlled: true,
                                          context: context,
                                          backgroundColor: Colors.white,
                                          constraints: BoxConstraints(
                                            maxWidth: double.infinity,
                                            maxHeight: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.85,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadiusDirectional.only(
                                              topEnd: Radius.circular(25.r),
                                              topStart: Radius.circular(25.r),
                                            ),
                                          ),
                                          builder: (context) {
                                            return BlocProvider.value(
                                              value: invoiceCubit,
                                              child: InvoiceBottomSheet(
                                                carModel: widget.carModel,
                                                invoiceModel:
                                                    invoiceCubit.data!,
                                                onExpanded: (value) => setState(
                                                    () => see = !value),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: ADGradientButton(
                                        locale.isDirectionRTL(context)
                                            ? "الفاتورة "
                                            : "Invoice ",
                                        height: 55.h,
                                        backgroundColor:
                                            buttonWhiteColor(context),
                                        textColor: mainTypographyColor(context),
                                        textStyle:
                                            AppTypography.mainTypographyColor18(
                                                context),
                                        customIcon: Image.asset(
                                          "assets/icons/stash_invoice.png",
                                          color: iconDefaultColor(context),
                                          width: 24.w,
                                          height: 24.h,
                                        ),
                                        border: Border.all(
                                          width: 2.w,
                                          color: strokeGrayColor(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                    },
                  ),
                )
              : SizedBox.shrink(),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
