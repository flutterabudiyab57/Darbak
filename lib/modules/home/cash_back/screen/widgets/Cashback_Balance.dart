import 'package:bounce/bounce.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/core/constants/assets/assets.dart';
import 'package:darbak/language/locale.dart';

import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../widgets/Dashed_divider.dart';
import '../../../../widgets/components/ad_gradient_btn.dart';
import '../../../../widgets/components/ad_prim_text_form/ad_prim_text_form.dart';
import '../../../../widgets/components/showResponsive_Flushbar.dart';
import '../../../payment/blocs/invoice_cubit.dart';
import '../../bloc/cashback__cubit.dart';

class DaraksonBalanceWidget extends StatefulWidget {
  final double availableBalance;
  final double pendingCredit;
  final bool isEnabled;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;
  final String orderId;

  const DaraksonBalanceWidget({
    Key? key,
    required this.availableBalance,
    this.pendingCredit = 0,
    this.isEnabled = false,
    this.onToggle,
    this.onTap,
    required this.orderId,
  }) : super(key: key);

  @override
  State<DaraksonBalanceWidget> createState() => _DaraksonBalanceWidgetState();
}

class _DaraksonBalanceWidgetState extends State<DaraksonBalanceWidget>
    with SingleTickerProviderStateMixin {
  late bool _isToggled;
  final TextEditingController controller = TextEditingController();
  bool showClearButton = false;
  bool showApplyButton = true;
  double currentAppliedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _isToggled = widget.isEnabled;
    controller.addListener(() {
      setState(() {});
    });
  }

  void _handleToggle() {
    setState(() {
      _isToggled = !_isToggled;
    });
    widget.onToggle?.call(_isToggled);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleApplyOrClear(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final locale = AppLocalizations.of(context)!;
    final cashbackCubit = context.read<CashbackCubit>();
    final invoiceCubit = context.read<InvoiceCubit>();

    if (controller.text.isEmpty) {
      ResponsiveFlushbar.show(
        context,
        message: locale.isDirectionRTL(context)
            ? "يرجى إدخال المبلغ"
            : "Please enter amount",
        backgroundColor: Color(0xffF6A9A9),
        textColor: buttonRedColor(context),
      );
      return;
    }

    final double? amount = double.tryParse(controller.text);

    if (amount == null || amount < 0) {
      ResponsiveFlushbar.show(
        context,
        message: locale.isDirectionRTL(context)
            ? "يرجى إدخال مبلغ صحيح"
            : "Please enter a valid amount",
        backgroundColor: Color(0xffF6A9A9),
        textColor: buttonRedColor(context),
      );
      return;
    }

    if (amount > widget.availableBalance && amount != 0) {
      ResponsiveFlushbar.show(
        context,
        message: locale.isDirectionRTL(context)
            ? "المبلغ المدخل أكبر من الرصيد المتاح"
            : "Amount exceeds available balance",
        backgroundColor: Color(0xffF6A9A9),
        textColor: buttonRedColor(context),
      );
      return;
    }

    await invoiceCubit.getInvoice(context);

    if (invoiceCubit.data == null) {
      ResponsiveFlushbar.show(
        context,
        message: locale.isDirectionRTL(context)
            ? "فشل تحميل بيانات الفاتورة"
            : "Failed to load invoice data",
        backgroundColor: Color(0xffF6A9A9),
        textColor: buttonRedColor(context),
      );
      return;
    }

    await cashbackCubit.applyCashbackToOrder(
      orderId: widget.orderId,
      amount: amount,
    );

    await invoiceCubit.getInvoice(context);

    controller.clear();
  }

  void _handleCancelCashback(BuildContext context) async {
    final cashbackCubit = context.read<CashbackCubit>();
    final invoiceCubit = context.read<InvoiceCubit>();
    final locale = AppLocalizations.of(context)!;

    await invoiceCubit.getInvoice(context);

    if (invoiceCubit.data == null) {
      ResponsiveFlushbar.show(
        context,
        message: locale.isDirectionRTL(context)
            ? "فشل تحميل بيانات الفاتورة"
            : "Failed to load invoice data",
        backgroundColor: Color(0xffF6A9A9),
        textColor: Colors.red,
      );
      return;
    }

    await cashbackCubit.applyCashbackToOrder(
      orderId: widget.orderId,
      amount: 0,
    );

    await invoiceCubit.getInvoice(context);
  }

  double _getExpectedCashback(BuildContext context) {
    final invoiceCubit = context.read<InvoiceCubit>();

    if (invoiceCubit.data?.cashback?.expectedCashbackAmount != null) {
      return invoiceCubit.data!.cashback!.expectedCashbackAmount!;
    }

    return widget.pendingCredit;
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;

    return BlocListener<CashbackCubit, CashbackState>(
      listener: (context, state) {
        if (state is CashbackDataState) {
          if (state.applyCashbackResponse != null &&
              !state.isApplyingCashback) {
            final response = state.applyCashbackResponse!;
            ResponsiveFlushbar.show(
              context,
              message: response.message,
              backgroundColor: buttonGreenColor(context),
              textColor: Colors.white,
            );
            if (response.data.clearedAmount != null) {
              setState(() {
                controller.clear();
                currentAppliedAmount = 0.0;
              });
            } else if (response.data.appliedAmount != null) {
              setState(() {
                currentAppliedAmount = response.data.appliedAmount!;
              });
            }
          }
          if (state.applyCashbackError != null && !state.isApplyingCashback) {
            ResponsiveFlushbar.show(
              context,
              message: state.applyCashbackError!,
              backgroundColor: mainTypographyColor(context),
              textColor: buttonRedColor(context),
            );
          }
        }
      },
      child: GestureDetector(
        onTap: widget.onTap ?? _handleToggle,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Container(
            width: double.infinity,
            padding:
                EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.hs(context)),
            decoration: ShapeDecoration(
              color: buttonWhiteColor(context),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1.5.w,
                  color: strokeGrayColor(context),
                ),
                borderRadius: BorderRadius.circular(15.r),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 35.ws(context),
                      height: 35.hs(context),
                      decoration: ShapeDecoration(
                        color: buttonWhiteColor(context),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1.5.w,
                            color: strokeGrayColor(context),
                          ),
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          Assets.icon_wallet,
                          height: 16.hs(context),
                          width: 17.ws(context),
                          color: iconDefaultColor(context),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.ws(context)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locale.isDirectionRTL(context)
                              ? "رصيد دراكسون"
                              : "Darakson Balance",
                          style: AppTypography.headingColor16(context),
                        ),
                        Row(
                          children: [
                            Text(
                              locale.isDirectionRTL(context)
                                  ? "الرصيد المتاح: "
                                  : "Available balance:",
                              style: AppTypography.headingColor16(context),
                            ),
                            Text(
                              widget.availableBalance.toStringAsFixed(0),
                              style:
                                  AppTypography.mainTypographyColor16(context),
                            ),
                            SizedBox(width: 5.w),
                            SvgPicture.asset(
                              Assets.icon_riyal,
                              height: 14.hs(context),
                              width: 13.ws(context),
                              color: mainTypographyColor(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: _handleToggle,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: 65.ws(context),
                        height: 30.hs(context),
                        decoration: ShapeDecoration(
                          color: _isToggled
                              ? iconDefaultColor(context)
                              : TextgrayColor(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        child: AnimatedAlign(
                          duration: Duration(milliseconds: 200),
                          alignment: _isToggled
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5.ws(context)),
                            width: 20.ws(context),
                            height: 20.hs(context),
                            decoration: ShapeDecoration(
                              color: buttonWhiteColor(context),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                BlocBuilder<InvoiceCubit, InvoiceState>(
                  builder: (context, invoiceState) {
                    final expectedCashback = _getExpectedCashback(context);

                    if (expectedCashback > 0) {
                      return Column(
                        children: [
                          SizedBox(height: 10.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 15.hs(context)),
                            decoration: ShapeDecoration(
                              color: buttonGreenColor(context).withOpacity(.15),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1.5.w,
                                  color: buttonGreenColor(context),
                                ),
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'IBMPlexSansArabic',
                                  color: buttonGreenColor(context),
                                  fontSize: 12.sps(context),
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: locale.isDirectionRTL(context)
                                        ? "رصيد قيد الإضافة: بعد انتهاء الرحلة ستحصل على ${expectedCashback.toStringAsFixed(0)} "
                                        : "Added: After the trip ends, you will receive ${expectedCashback.toStringAsFixed(0)} ",
                                  ),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: SvgPicture.asset(
                                      Assets.icon_riyal,
                                      height: 14.hs(context),
                                      width: 14.ws(context),
                                      color: buttonGreenColor(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
                AnimatedSize(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isToggled
                      ? BlocBuilder<CashbackCubit, CashbackState>(
                          builder: (context, state) {
                            final isLoading = state is CashbackDataState &&
                                state.isApplyingCashback;

                            return Column(
                              children: [
                                SizedBox(height: 10.h),
                                dashedDivider(context),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    Text(
                                      locale.isDirectionRTL(context)
                                          ? "المبلغ المراد استخدامه"
                                          : "Amount to be used",
                                      style: AppTypography.paragraphColor16(
                                          context),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child: ADPrimTextForm(
                                        controller: controller,
                                        type: TextInputType.numberWithOptions(
                                            decimal: true),
                                        label: locale.enteramount.toString(),
                                        pAssetIcon: Assets.icon_wallet,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      flex: 3,
                                      child: Bounce(
                                        onTap: isLoading
                                            ? null
                                            : () =>
                                                _handleApplyOrClear(context),
                                        child: ADGradientButton(
                                          isLoading
                                              ? (locale.isDirectionRTL(context)
                                                  ? "جاري"
                                                  : "Loading")
                                              : (locale.apply),
                                          backgroundColor: isLoading
                                              ? buttonSecondaryColor(context)
                                              : (controller.text.isNotEmpty
                                                  ? iconDefaultColor(context)
                                                  : buttonSecondaryColor(
                                                      context)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (currentAppliedAmount > 0) ...[
                                  SizedBox(height: 10.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w,
                                              vertical: 10.hs(context)),
                                          decoration: BoxDecoration(
                                            color: buttonGreenColor(context)
                                                .withOpacity(.10),
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                            border: Border.all(
                                              color: buttonGreenColor(context)
                                                  .withOpacity(.3),
                                              width: 1.w,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(width: 4.w),
                                              Expanded(
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'IBMPlexSansArabic',
                                                      color: buttonGreenColor(
                                                          context),
                                                      fontSize: 13.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: locale
                                                                .isDirectionRTL(
                                                                    context)
                                                            ? "سيتم خصم ${currentAppliedAmount.toStringAsFixed(0)} "
                                                            : "Will be deducted ${currentAppliedAmount.toStringAsFixed(0)} ",
                                                      ),
                                                      WidgetSpan(
                                                        alignment:
                                                            PlaceholderAlignment
                                                                .middle,
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      4.w),
                                                          child:
                                                              SvgPicture.asset(
                                                            Assets.icon_riyal,
                                                            height: 12
                                                                .hs(context),
                                                            width: 11
                                                                .ws(context),
                                                            color:
                                                                buttonGreenColor(
                                                                    context),
                                                          ),
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: locale
                                                                .isDirectionRTL(
                                                                    context)
                                                            ? "من رصيدك"
                                                            : "from your balance",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Bounce(
                                        onTap: isLoading
                                            ? null
                                            : () =>
                                                _handleCancelCashback(context),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w,
                                              vertical: 10.hs(context)),
                                          decoration: BoxDecoration(
                                            color: buttonRedColor(context)
                                                .withOpacity(.1),
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                            border: Border.all(
                                              color: buttonRedColor(context),
                                              width: 1.w,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.close,
                                                size: 17.sp,
                                                color: buttonRedColor(context),
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(
                                                locale.cancel.toString(),
                                                style:
                                                    AppTypography.buttonRed14(
                                                        context),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            );
                          },
                        )
                      : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
