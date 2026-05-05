import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/cars/data/models/cars_model.dart';
import 'package:darbak/modules/home/payment/data/models/invoice_model.dart'
    hide Icon;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/assets/app_colors.dart';
import '../../../../core/constants/assets/assets.dart';
import '../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../core/style/style.dart';
import '../../../widgets/Dashed_divider.dart';
import '../blocs/invoice_cubit.dart';

class InfoInvoiceWidget extends StatefulWidget {
  final ValueChanged<bool> onExpanded;
  final InvoiceModel invoiceModel;
  final DataCars? carModel;

  const InfoInvoiceWidget({
    super.key,
    required this.onExpanded,
    required this.invoiceModel,
    this.carModel,
  });

  @override
  State<InfoInvoiceWidget> createState() => _InfoInvoiceWidgetState();
}

class _InfoInvoiceWidgetState extends State<InfoInvoiceWidget> {
  final GlobalKey columnlKey = GlobalKey();
  late bool _see;
  double? height;

  @override
  void initState() {
    super.initState();
    _see = false;
    height = 0.0;
  }

  void changeExpandedValue() {
    final currentContext = columnlKey.currentContext;
    final box = currentContext?.findRenderObject() as RenderBox?;

    if (_see) {
      setState(() {
        height = 0.0;
        _see = !_see;
      });
      widget.onExpanded(_see);
    } else {
      setState(() {
        height = box?.size.height ?? 0.0;
        _see = !_see;
      });
      widget.onExpanded(_see);
    }
  }

  bool _isNotZero(dynamic value) {
    return (double.tryParse(value.toString()) ?? 0) != 0;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return BlocConsumer<InvoiceCubit, InvoiceState>(
      listener: (context, state) {
        if (state is InvoiceLoading) {
          const LoadingIndicator();
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            _buildBookingDetailsSection(context, locale),
            SizedBox(height: 16.h),
            _buildInsuranceAndAddOnsSection(context, locale), 
            SizedBox(height: 16.h),
            _buildTotalPriceSection(context, locale),
          ],
        );
      },
    );
  }

  Widget _buildBookingDetailsSection(
    BuildContext context,
    AppLocalizations? locale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Text(
            locale!.bookingDetails.toString(),
            style: AppTypography.headingColor18(context),
          ),
        ),
        SizedBox(height: 15.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15.w),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: backgroundColor(context),
            border: Border.all(color: strokeGrayColor(context), width: 1.5.w),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            children: [
              _buildDaysHeader(context, locale),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      context,
                      title: locale.reservation.toString(),
                      location:
                          widget.invoiceModel.order!.receivePlace!.toString(),
                      time: widget.invoiceModel.order!.receiveTime.toString(),
                      date: widget.invoiceModel.order!.receiveDate!.toString(),
                      isActive: false,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildCard(
                      context,
                      title: locale.delivery.toString(),
                      location:
                          widget.invoiceModel.order!.deliverPlace!.toString(),
                      time: widget.invoiceModel.order!.deliverDate.toString(),
                      date: widget.invoiceModel.order!.deliverDate!.toString(),
                      isActive: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaysHeader(BuildContext context, AppLocalizations locale) {
    final isRTL = locale.isDirectionRTL(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isRTL ? "عدد أيام الحجز" : "Booking days",
          style: AppTypography.headingColor16(context),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: mainTypographyColor(context).withOpacity(0.15),
            borderRadius: BorderRadius.circular(50.r),
            border: Border.all(color: mainTypographyColor(context)),
          ),
          child: Text(
            isRTL
                ? "${widget.invoiceModel.diff} يوم"
                : "${widget.invoiceModel.diff} day",
            style: AppTypography.mainTypographyColor16(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String location,
    required String time,
    required String date,
    required bool isActive,
  }) {
    final borderColor =
        isActive ? const Color(0xFFC61919) : const Color(0xFF34C441);
    final bgColor =
        isActive ? const Color(0xffC71A1A) : const Color(0xff34C441);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: buttonWhiteColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: strokeGrayColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: bgColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: borderColor),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    Assets.icon_picker,
                    width: 20.w,
                    height: 20.w,
                    color: bgColor,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(title, style: AppTypography.headingColor16(context)),
            ],
          ),
          SizedBox(height: 10.h),
          _infoRow(context, "الموقع", location, Icons.location_on_outlined),
          SizedBox(height: 6.h),
          _infoRow(context, "الوقت", time, Icons.access_time),
          SizedBox(height: 6.h),
          _infoRow(context, "التاريخ", date, Icons.calendar_month),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20.sp, color: paragraphColor(context)),
            SizedBox(width: 6.w),
            Text(label, style: AppTypography.paragraphColor14(context)),
          ],
        ),
        Text(
          value,
          style: AppTypography.paragraphColor14(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }
  bool _isInsuranceExpanded = false;

  Widget _buildInsuranceAndAddOnsSection(
      BuildContext context,
      AppLocalizations? locale,
      ) {
    final isRTL = locale!.isDirectionRTL(context);
    final orderAdditions = widget.invoiceModel.order?.orderAdditions ?? [];

    final insuranceFeatures = orderAdditions.where((a) {
      final name = a.name.toLowerCase();
      return name.contains("تأمين") ||
          name.contains("insurance") ||
          name.contains("درع") ||
          name.contains("shield") ||
          name.contains("أساسي") ||
          name.contains("basic") ||
          name.contains("شامل") ||
          name.contains("full");
    }).toList();

    final additionsFeatures = orderAdditions.where((a) {
      final name = a.name.toLowerCase();
      return !name.contains("تأمين") &&
          !name.contains("insurance") &&
          !name.contains("درع") &&
          !name.contains("shield") &&
          !name.contains("أساسي") &&
          !name.contains("basic") &&
          !name.contains("شامل") &&
          !name.contains("full");
    }).toList();

    if (insuranceFeatures.isEmpty && additionsFeatures.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: buttonWhiteColor(context),
        border: Border.all(color: strokeGrayColor(context), width: 1.5.w),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(
                    () => _isInsuranceExpanded = !_isInsuranceExpanded),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: buttonTextColor(context),
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                              width: 1.w,
                              color: strokeGrayColor(context)),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            Assets.icon_insurance,
                            width: 21.w,
                            height: 24.w,
                            color: iconDefaultColor(context),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        isRTL ? 'التأمين والإضافات' : 'Insurance & Add-ons',
                        style: AppTypography.headingColor16(context),
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    turns: _isInsuranceExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 32.sp,
                      color: iconGrayColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                bottom: 12.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dashedDivider(context),
                  SizedBox(height: 12.h),

                  if (insuranceFeatures.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        isRTL ? 'نوع التأمين' : 'Insurance Type',
                        style: AppTypography.headingColor16(context),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      alignment: WrapAlignment.start,
                      children: insuranceFeatures.map((a) {
                        return _buildChip(context, a.name);
                      }).toList(),
                    ),
                  ],

                  if (additionsFeatures.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        isRTL ? 'الإضافات' : 'Additions',
                        style: AppTypography.headingColor16(context),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      alignment: WrapAlignment.start,
                      children: additionsFeatures.map((a) {
                        return _buildChip(context, a.name);
                      }).toList(),
                    ),
                  ],

                  SizedBox(height: 8.h),
                ],
              ),
            ),
            crossFadeState: _isInsuranceExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );  }

  Widget _buildChip(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor(context),
        border: Border.all(color: strokeGrayColor(context), width: 1.w),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            Assets.icon_insurance,
            width: 11.w,
            height: 14.w,
            color: paragraphColor(context),
          ),
          SizedBox(width: 4.w),

          Text(
            label,
            style: AppTypography.paragraphColor12(context),
            textAlign: TextAlign.right,
          ),

        ],
      ),
    );
  }
  bool _isExpanded = false;

  Widget _buildTotalPriceSection(
    BuildContext context,
    AppLocalizations? locale,
  ) {
    final isRTL = locale!.isDirectionRTL(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        border: Border.all(color: strokeGrayColor(context), width: 1.5.w),
        borderRadius: BorderRadius.circular(15.r),
        color: buttonWhiteColor(context),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              widget.onExpanded(_isExpanded);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: buttonTextColor(context),
                          borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                                width: 1.w,
                                color:strokeGrayColor(context))
                        ),
                        child: Center(
                          child: SvgPicture.asset(Assets.icon_payment_summry,
                              width: 22.w,
                              height: 18.w,
                              color: buttonGreenColor(context)),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        isRTL ? 'ملخص الدفع' : 'Payment Summary',
                        style: AppTypography.headingColor16(context),
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 35.sp,
                      color: iconGrayColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                bottom: 12.h,
              ),
              child: Column(
                children: [
                  dashedDivider(context),
                  SizedBox(height: 8.h),
                  if (_isNotZero(widget.invoiceModel.carPrice))
                    PriceRow(
                      title: locale.rent.toString(),
                      value: widget.invoiceModel.carPrice.toString(),
                    ),
                  if (_isNotZero(widget.invoiceModel.featuresPrice))
                    PriceRow(
                      title: locale.additions.toString(),
                      value: widget.invoiceModel.featuresPrice.toString(),
                    ),
                  if (_isNotZero(widget.invoiceModel.authorizationFee))
                    PriceRow(
                      title: locale.tam.toString(),
                      value: widget.invoiceModel.authorizationFee.toString(),
                    ),
                  if (_isNotZero(widget.invoiceModel.areaPricing))
                    PriceRow(
                      title: locale.transfer.toString(),
                      value: widget.invoiceModel.areaPricing.toString(),
                    ),
                  if (_isNotZero(widget.invoiceModel.order?.visaAmout ?? 0))
                    PriceRow(
                        title: locale.visaDiscount.toString(),
                        value: widget.invoiceModel.order!.visaAmout.toString(),
                        titleColor: buttonRedColor(context)),
                  if (_isNotZero(widget.invoiceModel.price))
                    PriceRow(
                      title: locale.total2.toString(),
                      value: widget.invoiceModel.price.toString(),
                    ),
                  if (_isNotZero(widget.invoiceModel.membershipDiscount))
                    PriceRow(
                        title: locale.memberDiscount.toString(),
                        value:
                            widget.invoiceModel.membershipDiscount.toString(),
                        titleColor: buttonRedColor(context)),
                  if (_isNotZero(widget.invoiceModel.carDiscount))
                    PriceRow(
                        title: locale.carDiscount.toString(),
                        value: widget.invoiceModel.carDiscount.toString(),
                        titleColor: buttonRedColor(context)),
                  if (_isNotZero(widget.invoiceModel.deliveryValue ?? 0))
                    PriceRow(
                      title: isRTL ? "رسوم التوصيل" : "Delivery Value",
                      value:
                          (widget.invoiceModel.deliveryValue ?? 0).toString(),
                    ),
                  if (_isNotZero(widget.invoiceModel.beforeTax))
                    PriceRow(
                      title: locale.netAmount.toString(),
                      value: widget.invoiceModel.beforeTax.toString(),
                    ),
                  if (_isNotZero(widget.invoiceModel.taxValue))
                    PriceRow(
                      title: locale.taxValue.toString(),
                      value: widget.invoiceModel.taxValue.toString(),
                    ),
                  if (_isNotZero(widget.invoiceModel.couponValue))
                    PriceRow(
                        title: isRTL ? "خصم الكوبون" : "Coupon Discount",
                        value: widget.invoiceModel.couponValue.toString(),
                        titleColor: buttonRedColor(context)),
                  if (_isNotZero(widget.invoiceModel.pointsValue))
                    PriceRow(
                        title: isRTL ? "خصم النقاط" : "Points Discount",
                        value: widget.invoiceModel.pointsValue.toString(),
                        titleColor: buttonRedColor(context)),
                  SizedBox(height: 8.h),
                  dashedDivider(context),
                  if (_isNotZero(widget.invoiceModel.total))
                    PriceRow(
                      title: locale.grandTotal.toString(),
                      value: widget.invoiceModel.total.toString(),
                    ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

class PriceRow extends StatelessWidget {
  final String title;
  final String value;
  final String? icon;
  final Color? titleColor;

  const PriceRow({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: AppTypography.paragraphColor16(context).copyWith(
                color: titleColor ?? paragraphColor(context),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: AppTypography.paragraphColor16(context).copyWith(
                      color: titleColor ?? paragraphColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 4.w),
                SvgPicture.asset(
                  Assets.icon_riyal,
                  width: 16.w,
                  height: 16.w,
                  color: titleColor ?? paragraphColor(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
