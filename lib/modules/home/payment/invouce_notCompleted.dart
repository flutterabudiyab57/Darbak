import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/additions/presentaion/pages/additions_screen.dart';
import 'package:darbak/modules/home/all_bookings/data/model/check_order_step_model.dart';
import 'package:darbak/modules/home/blocs/booking_cubit/booking_cubit.dart';
import 'package:darbak/modules/home/booking_confirmed/bookingConfirmed.dart';
import 'package:darbak/modules/home/cars/data/models/cars_model.dart';
import 'package:darbak/modules/home/payment/data/models/credit_card_model.dart';
import 'package:darbak/modules/home/payment/widget/info_invoice_notCompleted.dart';
import 'package:darbak/modules/widgets/components/ad_gradient_btn.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../shared/commponents.dart';
import '../../widgets/components/appbar.dart';
 import '../../widgets/strike_through_text.dart';
import '../additions/presentaion/blocs/addition_cubit/additions_cubit.dart';
import '../all_bookings/data/model/booking_model.dart';
import 'blocs/invoice_cubit.dart';

class InvoiceNotCompletedUI extends StatefulWidget {
  final DataCars? carModel;
  // final InvoiceModel? invoiceModel;
  final bool? isApplePay;
  final bool? isNotCompletedOrder;
  final bool? hideAddition;
  final Datum? allBookingData;
  final String? totalApplePay;
  final String? orderID;
  final PaymentMethod? paymentType;
  final CheckOrderStepModel? checkOrderStepModel;

  const InvoiceNotCompletedUI({
    Key? key,
    this.checkOrderStepModel,
    this.allBookingData,
    this.carModel,
    // this.invoiceModel,
    this.isApplePay,
    this.isNotCompletedOrder,
    this.totalApplePay,
    this.orderID,
    this.hideAddition,
    this.paymentType,
  }) : super(key: key);

  @override
  State<InvoiceNotCompletedUI> createState() => _InvoiceNotCompletedUIState();
}

class _InvoiceNotCompletedUIState extends State<InvoiceNotCompletedUI> {
  bool? see = true;
  @override
  void initState() {
    super.initState();
  }
  // getInvoice() async {
  //   await BlocProvider.of<AdditionsCubit>(context).checkOrderStep(orderId: widget.orderID);
  // }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        bottomNavigationBar: Container(
          width: size.width,
          decoration: BoxDecoration(),
          child: BlocProvider.of<BookingCubit>(context).selectedPaymentMethods !=
              PaymentMethod.visa
              ? BlocConsumer<InvoiceCubit, InvoiceState>(
            listener: (context, state) {},
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.symmetric(
                    vertical: size.height * 0.018, horizontal: 15.sp),
                child: state is InvoiceLoading
                    ? Center(child: LoadingIndicator())
                    : Container(
                  child: Bounce(
                    onTap: bookNow,
                    child: ADGradientButton(
                        locale.bookNow.toString()),
                  ),
                ),
              );
            },
          )
              : Padding(
            padding: EdgeInsets.symmetric(
                vertical: size.height * 0.018, horizontal: 15.sp),
            child: BlocConsumer<InvoiceCubit, InvoiceState>(
              listener: (context, state) {},
              builder: (context, state) {
                return state is InvoiceLoading
                    ? Center(child: LoadingIndicator())
                    : Container(
                  height: size.height * 0.065,
                  child: Bounce(
                    onTap: bookNowWithVisa,
                    child: ADGradientButton(
                        locale.bookNow.toString()),
                  ),
                );
              },
            ),
          ),
        ),
        appBar: CustomAppBar(
          title: locale.invoice.toString(),
          showBackButton: true,
          // showThemeToggle: true,
        ),
        body: BlocConsumer<InvoiceCubit, InvoiceState>(
          listener: (context, state) {
            if (state is PaymentSuccess) {
              if (context.read<BookingCubit>().selectedPaymentMethods ==
                  PaymentMethod.visa) {
                context.go(
                  '/web-payment',
                  extra: state.paymentStepModel.paymentUrl,
                );
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
              Fluttertoast.showToast(
                msg: locale.checkCardDetailsShort,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Color(0xffF6A9A9),
                textColor: Colors.red,
                fontSize: 16.sp,
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  ///------------First Widget Container------------
                  Container(
                    width: size.width,
                    height: 70.sp,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    child: Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: size.width * 0.06),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 20.sp,
                                height: 20.sp,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                child: Center(
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 3.0),
                                child: Text(
                                  locale.bookingDetails.toString(),
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.circle_outlined,
                                color: Colors.black54,
                                size: 18,
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 3.0),
                                child: Text(
                                  locale.payment.toString(),
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  defaultSizeBoxTwo(size),

                  ///------------second Widget  details--------------------
                  Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: size.width * 0.04),
                    child: Row(
                      children: [
                        Text(
                          locale.carSelected.toString(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        ///----------SOON-----------
                        Spacer(),
                        BlocConsumer<AdditionsCubit, AdditionsState>(
                          listener: (context, state) {
                            if (state is CheckOrderStateLoading) {
                              LoadingIndicator();
                            }
                          },
                          builder: (context, state) {
                            return GestureDetector(
                              onTap: () async {
                                navigateTo(
                                    context,
                                    AdditionsScreen(
                                      fromAddAdditions: true,
                                      datum: widget.carModel,
                                      fromNotCompleted: true,
                                      checkOrderStepModel:
                                      BlocProvider.of<AdditionsCubit>(
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
                                      fontFamily: 'IBMPlexSansArabic',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                  Container(
                                    height: 1,
                                    width: 50.sp,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  defaultSizeBoxTwo(size),
                  Container(
                    width: double.infinity,
                    height: size.height * 0.09,
                    margin: const EdgeInsets.symmetric(horizontal: 15.0),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            width: 1.2),
                        borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 4,
                            child: Image.network(
                                widget.carModel!.photo.toString())),
                        Text(
                          widget.carModel!.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Row(
                            children: [
                              StrikethroughText(
                                text: widget.carModel!.priceBefore.toString(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),                              Text(
                                widget.carModel!.priceAfter.toString() +
                                    locale.sar.toString(),
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                              Text(
                                "/" + locale.day.toString(),
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.5)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  defaultSizeBoxTwo(size),

                  ///------------END second Widget Car details
                  InfoInvoiceNotCompletedWidget(
                    orderID: widget.orderID,
                    onExpanded: (value) => setState(() => see = !value),
                  )
                ],
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
}
