import 'dart:io';

import 'package:bounce/bounce.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/modules/home/payment/widget/info_invoice.dart';
import 'package:darbak/modules/home/payment/widget/info_invoice_notCompleted.dart';
import 'package:darbak/modules/home/payment/widget/web_payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/assets/app_colors.dart';
import '../../../core/constants/assets/assets.dart';
import '../../../core/helpers/helper_fun.dart';
import '../../../language/locale.dart';
import '../../../shared/commponents.dart';
import '../../widgets/Dashed_divider.dart';
import '../../widgets/components/ad_gradient_btn.dart';
import '../../widgets/components/appbar.dart';
import '../additions/presentaion/blocs/addition_cubit/additions_cubit.dart';
import '../additions/presentaion/pages/additions_screen.dart';
import '../all_bookings/data/model/booking_model.dart';
import '../all_bookings/data/model/check_order_step_model.dart';
import '../blocs/booking_cubit/booking_cubit.dart';
import '../booking_confirmed/bookingConfirmed.dart';
import '../cars/data/models/cars_model.dart';
import '../cars/presentaion/widget/car_tile.dart';
import '../profile/blocs/profile_cubit/profile_cubit.dart';
import '../profile/page/widget/login_noAuth.dart';
import 'blocs/invoice_cubit.dart';
import 'data/models/credit_card_model.dart';
import 'data/models/invoice_model.dart' hide Icon;

class InvoiceUI extends StatefulWidget {
  final DataCars? carModel;
  final InvoiceModel? invoiceModel;
  final bool? isApplePay;
  final bool? isNotCompletedOrder;
  final bool? hideAddition;
  final Datum? allBookingData;
  final String? totalApplePay;
  final String? orderID;
  final PaymentMethod? paymentType;
  final CheckOrderStepModel? checkOrderStepModel;

  const InvoiceUI({
    Key? key,
    this.checkOrderStepModel,
    this.allBookingData,
    this.carModel,
    this.invoiceModel,
    this.isApplePay,
    this.isNotCompletedOrder,
    this.totalApplePay,
    this.orderID,
    this.hideAddition,
    this.paymentType,
  }) : super(key: key);

  @override
  State<InvoiceUI> createState() => _InvoiceUIState();
}

class _InvoiceUIState extends State<InvoiceUI> {
  bool? see = true;

  @override
  void initState() {
    getInvoice();
    super.initState();
  }

  getInvoice() async {
    if (widget.isNotCompletedOrder == true) {
      // await BlocProvider.of<InvoiceCubit>(context).getInvoiceNotCompletedOrder(context,widget.orderID);
      // await BlocProvider.of<AdditionsCubit>(context).checkOrderStep(orderId: widget.orderID);
    } else {
      await BlocProvider.of<InvoiceCubit>(context).getInvoice(context);
      _checkForceCashPayment();
    }
  }

  void _checkForceCashPayment() {
    final invoiceData = BlocProvider.of<InvoiceCubit>(context).data;

    if (invoiceData != null && invoiceData.forceCashPayment == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showForceCashPaymentDialog();
      });
    }
  }

  void _showForceCashPaymentDialog() {
    final locale = AppLocalizations.of(context)!;

    BlocProvider.of<BookingCubit>(context)
        .setPaymentMethods(PaymentMethod.cash);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: backgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400.w,
              maxHeight: 300.h,
            ),
            child: Padding(
              padding: EdgeInsets.all(20.sp),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    locale.paymentMethodUpdated,
                    style: AppTypography.headingColor18(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    locale.cashbackCovered100Percent,
                    style: AppTypography.paragraphColor14(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  Bounce(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: ADGradientButton(locale.ok),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final isRTL = locale.isDirectionRTL(context);
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor(context),
        bottomNavigationBar: Container(
          width: size.width,
          decoration: const BoxDecoration(),
          child: Builder(
            builder: (context) {
              final selectedPaymentMethod =
                  BlocProvider.of<BookingCubit>(context).selectedPaymentMethods;

              final isVisa = selectedPaymentMethod == PaymentMethod.visa;
              final isMadfou = selectedPaymentMethod == PaymentMethod.madfou;
              final isTamara = selectedPaymentMethod == PaymentMethod.tamara;
              final isCash = selectedPaymentMethod == PaymentMethod.cash;
              final isPoints = selectedPaymentMethod == PaymentMethod.points;
              if (!isVisa &&
                  !isMadfou &&
                  !isCash &&
                  !isPoints &&
                  !isTamara &&
                  Platform.isIOS) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: size.height * 0.018,
                    horizontal: 15.sp,
                  ),
                  child: Container(),
                );
              }
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.018,
                  horizontal: 15.sp,
                ),
                child: BlocConsumer<InvoiceCubit, InvoiceState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    if (state is InvoiceLoading) {
                      return Center(
                        child: Center(
                            child: CircularProgressIndicator(
                          strokeWidth: 3.w,
                        )),
                      );
                    }

                    void Function()? onTap;
                    if (isVisa) {
                      onTap = bookNowWithVisa;
                    } else if (isMadfou) {
                      onTap = bookNowWithMadfou;
                    } else if (isTamara) {
                      onTap = bookNowWithTamara;
                    } else if (isPoints) {
                      onTap = bookNow;
                    } else {
                      onTap = bookNow;
                    }

                    return Container(
                      height: size.height * 0.065,
                      child: Bounce(
                        onTap: onTap,
                        child: ADGradientButton(
                          locale.payNow,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        appBar: CustomAppBar(
          title: locale.invoice.toString(),
          showBackButton: true,
          // showThemeToggle: true,
        ),
        body: BlocConsumer<InvoiceCubit, InvoiceState>(
          listener: (context, state) {
            if (state is InvoiceSuccess ||
                state is PaymentSuccess ||
                state is InvoiceLoading ||
                state is CheckOrderStateSuccess) {
              Center(
                child: Lottie.asset("assets/anim/loader_invoice.json",
                    width: 80.w),
              );
            }
            if (state is InvoiceLoading) {
              Center(
                child: Lottie.asset("assets/anim/loader_invoice.json",
                    width: 80.w),
              );
            }
            if (state is PaymentSuccess) {
              final selectedPaymentMethod =
                  context.read<BookingCubit>().selectedPaymentMethods;

              final invoiceData = BlocProvider.of<InvoiceCubit>(context).data;
              final isForceCash = invoiceData?.forceCashPayment == true;

              if (isForceCash) {
                BookingConfirmedBottomSheet.show(
                  context,
                  orderId: widget.orderID.toString(),
                  carName: widget.carModel?.name,
                  total: BlocProvider.of<InvoiceCubit>(context)
                      .data
                      ?.total
                      ?.toString(),
                );
                return;
              }

              if (selectedPaymentMethod == PaymentMethod.visa ||
                  selectedPaymentMethod == PaymentMethod.madfou ||
                  selectedPaymentMethod == PaymentMethod.tamara) {
                navigateTo(
                    context,
                    WebPayment(
                      url: state.paymentStepModel.paymentUrl,
                    ));
              } else {
                BookingConfirmedBottomSheet.show(
                  context,
                  orderId: widget.orderID.toString(),
                  carName: widget.carModel?.name,
                  total: BlocProvider.of<InvoiceCubit>(context)
                      .data
                      ?.total
                      ?.toString(),
                );
              }
            } else if (state is InvoiceFailed) {
              Navigator.pop(context);

              final selectedPaymentMethod =
                  context.read<BookingCubit>().selectedPaymentMethods;

              if (selectedPaymentMethod == PaymentMethod.points) {
                HelperFunctions.dialog(
                  context: context,
                  title: locale.error.toString(),
                  body: locale.notEnoughPoints,
                );
              }

              if (selectedPaymentMethod == PaymentMethod.visa) {
                HelperFunctions.dialog(
                  context: context,
                  title: locale.error.toString(),
                  body: locale.checkCardDetails,
                );
              }
            }
          },
          builder: (context, state) {
            return Container(
              color: backgroundColor(context),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    defaultSizeBoxTwo(size),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.04),
                      child: Row(
                        children: [
                          Text(
                            locale.carSelected.toString(),
                            style: AppTypography.headingColor18(context),
                          ),
                          BlocConsumer<AdditionsCubit, AdditionsState>(
                            listener: (context, state) {},
                            builder: (context, state) {
                              return widget.isNotCompletedOrder == true
                                  ? GestureDetector(
                                      onTap: () async {
                                        await BlocProvider.of<AdditionsCubit>(
                                                context)
                                            .checkOrderStep(
                                                orderId: BlocProvider.of<
                                                        AdditionsCubit>(context)
                                                    .stepModel!
                                                    .order!
                                                    .id
                                                    .toString());
                                        navigateTo(
                                            context,
                                            AdditionsScreen(
                                              fromAddAdditions: true,
                                              datum: widget.carModel,
                                              fromNotCompleted: true,
                                              checkOrderStepModel: BlocProvider
                                                      .of<AdditionsCubit>(
                                                          context)
                                                  .stepModel,
                                            ));
                                        setState(() {
                                          widget.isNotCompletedOrder == false;
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Text(
                                            locale.additions.toString(),
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Container(
                                            height: 1.h,
                                            width: 50.sp,
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container();
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.sp),
                      margin: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: strokeGrayColor(context),
                          width: 1.5.w,
                        ),
                        borderRadius: BorderRadius.circular(15.r),
                        color: buttonWhiteColor(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Center(
                                    child: Image.network(
                                      widget.carModel!.photo,
                                      width: 150.w,
                                      height: 117.h,
                                      fit: BoxFit.fitWidth,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 159.w,
                                        height: 117.h,
                                        color: strokeGrayColor(context),
                                        child: Icon(
                                          Icons.directions_car,
                                          color: iconGrayColor(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.carModel!.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          AppTypography.mainTypographyColor15(
                                              context),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${widget.carModel!.priceAfter}',
                                          style: AppTypography.headingColor14(
                                              context),
                                        ),
                                        SizedBox(width: 3.w),
                                        SvgPicture.asset(
                                          Assets.icon_riyal,
                                          height: 14.h,
                                          width: 14.w,
                                          color: paragraphColor(context),
                                        ),
                                        Text(
                                          isRTL ? '/يوم' : '/day',
                                          style: AppTypography
                                              .mainTypographyColor14(context),
                                        ),
                                        SizedBox(width: 10.w),
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '${widget.carModel!.priceBefore}',
                                                  style: AppTypography
                                                      .mainTypographyColor14(
                                                          context),
                                                ),
                                                SizedBox(width: 6.w),
                                                SvgPicture.asset(
                                                  Assets.icon_riyal,
                                                  height: 14.h,
                                                  width: 14.w,
                                                  color: mainTypographyColor(
                                                      context),
                                                ),
                                                Text(
                                                  isRTL ? '/يوم' : '/day',
                                                  style: AppTypography
                                                      .mainTypographyColor14(
                                                          context),
                                                ),
                                              ],
                                            ),
                                            Positioned.fill(
                                              child: Center(
                                                child: Transform.rotate(
                                                  angle: -0.12,
                                                  child: Container(
                                                    height: 2.h,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 4.w),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFFF0004),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2.r),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),

                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      reverse: isRTL,
                                      child: Row(
                                        children: [
                                          _buildInfoBox(
                                            context,
                                            "assets/images/ftes.png",
                                            "${widget.carModel!.transmission}",
                                          ),
                                          SizedBox(width: 6.w),
                                          _buildInfoBox(
                                            context,
                                            "assets/images/seat.png",
                                            "${widget.carModel!.luggage}",
                                          ),
                                          SizedBox(width: 6.w),
                                          _buildInfoBox(
                                            context,
                                            "assets/images/car_seat.png",
                                            "${widget.carModel!.doors}",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          dashedDivider(context),
                          SizedBox(height: 12.h),
                          Text(
                            locale.freeServices,
                            style: AppTypography.mainTypographyColor18(context),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Text(
                                  locale.helpOnRoad,
                                  style: AppTypography.headingColor15(context)),
                              Spacer(),
                              Text(
                                  locale.receiveFullReturnFull,
                                  style: AppTypography.headingColor15(context)),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Text(
                                      locale.freeHoursEquals,
                                      style: AppTypography.headingColor15(
                                          context)),
                                  BlocBuilder<ProfileCubit, ProfileState>(
                                    builder: (context, state) {
                                      if (state is ProfileSuccess) {
                                        return Text(
                                            "${state.profileModel.membership!.extraHours} ${locale.hourSuffix}",
                                            style: AppTypography.headingColor15(
                                                context));
                                      }
                                      return const LoginNoAuth();
                                    },
                                  ),
                                  SizedBox(width: 6.w),
                                ],
                              ),
                              Spacer(),
                              Text(
                                  locale.accidentAssistance,
                                  style: AppTypography.headingColor15(context)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),

                    ///------------END second Widget Car details
                    widget.isNotCompletedOrder == true
                        ? InfoInvoiceNotCompletedWidget(
                            orderID: widget.orderID,
                            onExpanded: (value) => setState(() => see = !value),
                          )
                        : state is InvoiceSuccess || state is PaymentSuccess
                            ? InfoInvoiceWidget(
                                carModel: widget.carModel,
                                invoiceModel:
                                    BlocProvider.of<InvoiceCubit>(context)
                                        .data!,
                                onExpanded: (value) =>
                                    setState(() => see = !value))
                            : Center(
                                child: Lottie.asset(
                                    "assets/anim/loader_invoice.json",
                                    width: 80.w),
                              ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _resolveOrderId() {
    final cubitOrderId = context.read<BookingCubit>().orderID;
    if (cubitOrderId != null) return cubitOrderId.toString();
    return BlocProvider.of<AdditionsCubit>(context)
        .stepModel!
        .order!
        .id
        .toString();
  }

  PaymentMethod? _resolvePaymentType() {
    final selected = context.read<BookingCubit>().selectedPaymentMethods;
    if (selected != null) return selected;
    final stepPaymentType = BlocProvider.of<AdditionsCubit>(context)
        .stepModel
        ?.order
        ?.paymentType;
    return PaymentMethod.fromWire(stepPaymentType);
  }

  bookNowWithVisa() async {
    final input = CardInput.instance;
    try {
      await BlocProvider.of<InvoiceCubit>(context).activePaymentStep(
          CreditCardModel(
              orderId: _resolveOrderId(),
              paymentType: _resolvePaymentType(),
              securityCode: input.cvv,
              cardNumber: input.number,
              expiryMonth: input.expiryMonth,
              expiryYear: input.expiryYear,
              nameOnCard: input.holderName));
    } finally {
      input.clear();
    }
  }

  bookNow() async {
    final CreditCardModel cardModel = CreditCardModel(
      orderId: context.read<BookingCubit>().orderID?.toString() ?? widget.orderID,
      paymentType: context.read<BookingCubit>().selectedPaymentMethods ??
          widget.paymentType,
    );
    await BlocProvider.of<InvoiceCubit>(context).activePaymentStep(cardModel);
  }

  bookNowWithMadfou() async {
    final CreditCardModel cardModel = CreditCardModel(
      orderId: context.read<BookingCubit>().orderID?.toString() ?? widget.orderID,
      paymentType: context.read<BookingCubit>().selectedPaymentMethods,
    );
    await BlocProvider.of<InvoiceCubit>(context).activePaymentStep(cardModel);
  }

  bookNowWithTamara() async {
    final CreditCardModel cardModel = CreditCardModel(
      orderId: context.read<BookingCubit>().orderID?.toString() ?? widget.orderID,
      paymentType: context.read<BookingCubit>().selectedPaymentMethods,
    );
    await BlocProvider.of<InvoiceCubit>(context).activePaymentStep(cardModel);
  }
}

Widget _buildInfoBox(BuildContext context, String image, String text) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: strokeGrayColor(context),
        width: 1.5.w,
      ),
      borderRadius: BorderRadius.circular(8.r),
    ),
    padding: EdgeInsets.symmetric(vertical: 3.h,),
    child: ImageWithText(
      imagePath: image,
      text: text,
      rtlText: text,
    ),
  );
}
