import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../language/locale.dart';
import '../../../widgets/Dashed_divider.dart';
import '../../all_bookings/presentaion/page/bookDetailes.dart';
import '../../cars/data/models/cars_model.dart';
import '../blocs/invoice_cubit.dart';
import '../data/models/invoice_model.dart';

class InvoiceBottomSheet extends StatefulWidget {
  final ValueChanged<bool> onExpanded;
  final InvoiceModel invoiceModel;
  final DataCars? carModel;

  InvoiceBottomSheet({
    Key? key,
    required this.onExpanded,
    required this.invoiceModel,
    this.carModel,
  }) : super(key: key);

  @override
  State<InvoiceBottomSheet> createState() => _InvoiceBottomSheetState();
}

class _InvoiceBottomSheetState extends State<InvoiceBottomSheet> {
  bool? see = true;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<InvoiceCubit>(context).getInvoice(
      context,
    );
  }

  bool _isNotZero(dynamic value) {
    return (double.tryParse(value.toString()) ?? 0) != 0;
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.sp),
          topRight: Radius.circular(25.sp),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.sp),
          topRight: Radius.circular(25.sp),
        ),
        child: Container(
          color: backgroundColor(context),
          padding: EdgeInsets.all(10.sp),
          child: BlocBuilder<InvoiceCubit, InvoiceState>(
            builder: (context, state) {
              if (state is InvoiceLoading) {
                return Center(
                  child: LoadingIndicator(),
                );
              } else if (state is InvoiceSuccess) {
                final invoiceModel = state.invoiceModel;

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10.h,
                    children: [
                      Center(
                        child: Container(
                          width: 157.sp,
                          height: 8.sp,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.sp),
                            color: mainTypographyColor(context),
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            locale.isDirectionRTL(context)
                                ? "عدد أيام الحجز: "
                                : "Booking days: ",
                            style: AppTypography.headingColor14(context),
                          ),
                          Text(
                            locale.isDirectionRTL(context)
                                ? "${widget.invoiceModel.diff} يوم"
                                : "${widget.invoiceModel.diff} Day",
                            style: AppTypography.mainTypographyColor14(context),
                          ),
                        ],
                      ),

                      dashedDivider(context),

                      RowRentDetails(
                        title: locale.total.toString(),
                        resultTitle: invoiceModel.total.toString(),
                      ),

                      dashedDivider(context),

                      Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              locale.isDirectionRTL(context)
                                  ? "تفاصيل الفاتورة"
                                  : "Invoice details",
                              style: AppTypography.headingColor18(context),
                            ),
                          ],
                        ),
                      ),

                      if (_isNotZero(invoiceModel.carPrice))
                        RowRentDetails(
                          title: locale.isDirectionRTL(context)
                              ? " ${locale.rent.toString()} / ${widget.invoiceModel.diff} يوم"
                              : "${widget.invoiceModel.diff} Day / ${locale.rent.toString()}",
                          resultTitle:
                          (double.parse(invoiceModel.carPrice ?? '0.0'))
                              .toString(),
                        ),

                      ...invoiceModel.order!.orderAdditions
                          .where((addition) => _isNotZero(addition.price))
                          .map((addition) {
                        return RowRentDetails(
                          title: addition.name,
                          resultTitle: addition.price.toString(),
                        );
                      }).toList(),

                      if (_isNotZero(invoiceModel.authorizationFee))
                        RowRentDetails(
                          title: locale.tam.toString(),
                          resultTitle: invoiceModel.authorizationFee.toString(),
                        ),

                      if (_isNotZero(invoiceModel.areaPricing))
                        RowRentDetails(
                          title: locale.transfer.toString(),
                          resultTitle: invoiceModel.areaPricing.toString(),
                        ),

                      if (_isNotZero(invoiceModel.order?.visaAmout ?? 0))
                        RowRentDetails(
                          title: locale.visaDiscount.toString(),
                          resultTitle:
                          invoiceModel.order?.visaAmout.toString() ?? 'N/A',
                        ),

                      dashedDivider(context),

                      if (_isNotZero(invoiceModel.price))
                        RowRentDetails(
                          title: locale.total2.toString(),
                          resultTitle: invoiceModel.price.toString(),
                        ),

                      dashedDivider(context),

                      if (_isNotZero(invoiceModel.membershipDiscount))
                        RowRentDetails(
                          title: locale.memberDiscount.toString(),
                          resultTitle: invoiceModel.membershipDiscount.toString(),
                        ),

                      if (_isNotZero(invoiceModel.carDiscount))
                        RowRentDetails(
                          title: locale.carDiscount.toString(),
                          resultTitle: invoiceModel.carDiscount.toString(),
                        ),

                      if (_isNotZero(invoiceModel.cashbackDiscount))
                        RowRentDetails(
                          title: locale.CashbackDiscount.toString(),
                          resultTitle: invoiceModel.cashbackDiscount.toString(),
                        ),

                      if (_isNotZero(widget.invoiceModel.deliveryValue))
                        RowRentDetails(
                          title: locale.isDirectionRTL(context)
                              ? "رسوم التوصيل"
                              : "Delivery Value",
                          resultTitle:
                          widget.invoiceModel.deliveryValue.toString(),
                        ),

                      dashedDivider(context),

                      if (_isNotZero(invoiceModel.beforeTax))
                        RowRentDetails(
                          title: locale.netAmount.toString(),
                          resultTitle: invoiceModel.beforeTax.toString(),
                        ),

                      dashedDivider(context),

                      if (_isNotZero(invoiceModel.taxValue))
                        RowRentDetails(
                          title: locale.taxValue.toString(),
                          resultTitle: invoiceModel.taxValue.toString(),
                        ),

                      if (_isNotZero(invoiceModel.couponValue))
                        RowRentDetails(
                          title: locale.isDirectionRTL(context)
                              ? "خصم الكوبون"
                              : "Coupon Discount",
                          resultTitle: invoiceModel.couponValue.toString(),
                        ),

                      if (_isNotZero(invoiceModel.pointsValue))
                        RowRentDetails(
                          title: locale.isDirectionRTL(context)
                              ? "خصم النقاط"
                              : "Points Discount",
                          resultTitle: invoiceModel.pointsValue.toString(),
                        ),

                      dashedDivider(context),
                      RowRentDetails(
                        title: locale.grandTotal.toString(),
                        resultTitle: invoiceModel.total.toString(),
                      ),

                      SizedBox(height: 10.h),
                    ],
                  ),
                );
              } else if (state is InvoiceFailed) {
                return Text('Error: ${state.error}');
              }
              return SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}