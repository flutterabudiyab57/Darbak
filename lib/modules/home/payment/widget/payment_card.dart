import 'dart:ui';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/modules/home/blocs/booking_cubit/booking_cubit.dart';
import 'package:darbak/modules/widgets/components/ad_gradient_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/assets/app_colors.dart';
import '../../../../core/helpers/validation/form_validator.dart';
import '../../../../language/locale.dart';
import '../../../widgets/components/ad_prim_text_form/ad_prim_text_form.dart';
import '../data/models/credit_card_model.dart';

class PaymentMethodCard extends StatefulWidget {
  final Color color;
  final String text;
  final PaymentMethod method;
  final String? svg;

  const PaymentMethodCard({
    required this.color,
    required this.text,
    required this.method,
    this.svg,
  });

  @override
  State<PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<PaymentMethodCard> {
  var cardHolderName = TextEditingController();
  var cardNumber = TextEditingController();
  var cvv = TextEditingController();
  var month = TextEditingController();
  var year = TextEditingController();
  bool? see = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return _CardBackground(
      child: GestureDetector(
        onTap: () async {
          BlocProvider.of<BookingCubit>(context).setPaymentMethods(widget.method);
          if (widget.method == PaymentMethod.visa) {
            await showModalBottomSheet(
            isScrollControlled: true,
            elevation: 0,
            isDismissible: true,
            constraints: const BoxConstraints(maxWidth: double.infinity,),
            backgroundColor:buttonWhiteColor(context),
            context: context,
            builder: (context) {
              return Container(
                height: 0.9.sh,
                width: double.infinity,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.04.sw),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.h),
                          Container(
                            width: 80.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),
                              color: buttonWhiteColor(context),
                            ),
                          ),
                          SizedBox(height: 15.h),
                          ADPrimTextForm(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CardNumberFormatter(),
                            ],
                            sizeText: 20,
                            maxlenth: 19,
                            controller: cardNumber,
                            type: TextInputType.number,
                            label: locale.cardNumber,
                            pIcon: Icons.credit_card_sharp,
                            validat: (value) =>
                                FormValidator.creditValidate(
                                    context, value),
                          ),
                          SizedBox(height: 10.h),
                          ADPrimTextForm(
                            controller: cardHolderName,
                            type: TextInputType.name,
                            label: locale.cardHolderName,
                            pIcon: Icons.camera_front_rounded,
                            validat: (value) =>
                                FormValidator.nameValidate(
                                    context, value),
                          ),
                          SizedBox(height: 10.h),
                          ADPrimTextForm(
                            maxlenth: 2,
                            controller: month,
                            type: TextInputType.number,
                            label: locale.expireMonth,
                            pIcon: Icons.calendar_today,
                            auth: false,
                            validat: (value) => FormValidator.monthValidate(context, value),
                          ),
                          SizedBox(height: 10.h),
                          ADPrimTextForm(
                            maxlenth: 2,
                            controller: year,
                            type: TextInputType.number,
                            label: locale.expireYear,
                            pIcon: Icons.calendar_today,
                            auth: false,
                            validat: (value) => FormValidator.yearValidate(context, value, month.text),
                          ),
                          SizedBox(height: 10.h),
                          ADPrimTextForm(
                            maxlenth: 3,
                            controller: cvv,
                            type: TextInputType.number,
                            label: "CVV",
                            pIcon: Icons.credit_card_sharp,
                            auth: false,
                            validat: (value) =>
                                FormValidator.cvvValidate(
                                    context, value),
                          ),
                          SizedBox(height: 10.h),
                          GestureDetector(
                            onTap: bookNowWithVisa,
                            child: ADGradientButton(
                              locale.addPaymentCard,
                            ),
                          ),
                          SizedBox(height: 0.05.sh),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.02.sw,vertical:0.015.sw),
          child: Container(
            height: 57.h,
            width: 1.sw,
            decoration: BoxDecoration(
              border: Border.all(width: 2.w, color: strokeGrayColor(context)),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.03.sw),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: SvgPicture.asset(
                      widget.svg!,
                      fit: BoxFit.fill,
                      width: 45.w,
                      height: 18.h,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    this.widget.text,
                    style: AppTypography.mainTypographyColor18(context),
                  ),
                  Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26.w,
                    height: 26.h,
                    decoration: BoxDecoration(
                      color: BlocProvider.of<BookingCubit>(context)
                          .selectedPaymentMethods == widget.method
                          ? buttonPrimaryBgColor(context)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(50.r),
                      border: Border.all(
                        width: 1.5.w,
                        color: BlocProvider.of<BookingCubit>(context)
                            .selectedPaymentMethods == widget.method
                            ? buttonPrimaryBgColor(context)
                            : strokeGrayColor(context),
                      ),
                    ),
                    child: BlocProvider.of<BookingCubit>(context)
                        .selectedPaymentMethods == widget.method
                        ? Icon(
                      Icons.check,
                      size: 18.sp,
                      color: Colors.white,
                    )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bookNowWithVisa() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        CardInput.instance
          ..holderName = cardHolderName.text
          ..number = cardNumber.text.replaceAll("-", "").trim()
          ..cvv = int.parse(cvv.text)
          ..expiryMonth = int.parse(month.text.substring(0, 2))
          ..expiryYear = int.parse(year.text.substring(0, 2))
          ..isValid = true;
        Navigator.pop(context);
      });
    } else {
      setState(() {
        CardInput.instance.isValid = false;
      });
    }
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue previousValue,
      TextEditingValue nextValue,
      ) {
    var inputText = nextValue.text;

    if (nextValue.selection.baseOffset == 0) {
      return nextValue;
    }

    var bufferString = new StringBuffer();
    for (int i = 0; i < inputText.length; i++) {
      bufferString.write(inputText[i]);
      var nonZeroIndexValue = i + 1;
      if (nonZeroIndexValue % 4 == 0 && nonZeroIndexValue != inputText.length) {
        bufferString.write('-');
      }
    }

    var string = bufferString.toString();
    return nextValue.copyWith(
      text: string,
      selection: new TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}

class _CardBackground extends StatelessWidget {
  final Widget child;

  const _CardBackground({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.all(5.sp),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(6.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: this.child,
      ),
    ),
  );
}