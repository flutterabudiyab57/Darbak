
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/assets/app_colors.dart';
import '../../../../core/helpers/validation/form_validator.dart';
import '../../../../core/style/style.dart';
import '../../../../language/locale.dart';

class DynamicPhoneFieldWithCountry extends StatefulWidget {
  final TextEditingController controller;
  final Country? selectedCountry;
  final VoidCallback onCountryTap;

  const DynamicPhoneFieldWithCountry({
    Key? key,
    required this.controller,
    required this.selectedCountry,
    required this.onCountryTap,
  }) : super(key: key);

  @override
  State<DynamicPhoneFieldWithCountry> createState() =>
      _DynamicPhoneFieldWithCountryState();
}

class _DynamicPhoneFieldWithCountryState
    extends State<DynamicPhoneFieldWithCountry> {
  String? _dynamicMessage;
  Color _messageColor = Colors.grey;
  final _formKey = GlobalKey<FormFieldState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateValidation);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateValidation);
    super.dispose();
  }

  void _updateValidation() {
    setState(() {
      String? error = FormValidator.phoneValidateWithCountry(
        context,
        widget.controller.text,
        widget.selectedCountry?.phoneCode ?? '966',
      );

      if (widget.controller.text.isEmpty) {
        _dynamicMessage = null;
        _messageColor = Colors.grey;
      } else if (error == null) {
        _dynamicMessage = '✓ رقم الجوال صحيح';
        _messageColor = Colors.green;
      } else {
        _dynamicMessage = error;
        _messageColor = Colors.red;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: _formKey,
                      autovalidateMode: _autovalidateMode,
                      autofocus: false,
                      autocorrect: false,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(15),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: AppTypography.paragraphColor16(context),
                      controller: widget.controller,
                      keyboardType: TextInputType.phone,
                      onTap: () {
                        if (_formKey.currentState?.hasError ?? false) {
                          setState(() {
                            _autovalidateMode = AutovalidateMode.disabled;
                          });
                          _formKey.currentState?.reset();
                        }
                      },
                      onChanged: (value) {
                        if (_autovalidateMode == AutovalidateMode.disabled && value.isNotEmpty) {
                          setState(() {
                            _autovalidateMode = AutovalidateMode.onUserInteraction;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16.h,
                          horizontal: 12.w,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                          borderSide: BorderSide(
                            color: strokeGrayColor(context),
                            width: 2.w,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                          borderSide: BorderSide(
                            color: strokeGrayColor(context),
                            width: 2.w,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white70 : Colors.red.withValues(alpha: 0.4),
                            width: 1.w,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white70 : Colors.red.withValues(alpha: 0.4),
                            width: 1.w,
                          ),
                        ),
                        fillColor: backgroundColor(context),
                        filled: true,
                        hintStyle: AppTypography.paragraphColor15(context),
                        labelText: locale.phoneNumber,
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        labelStyle: AppTypography.paragraphColor16(context),
                        prefixIcon: Icon(
                          Icons.phone,
                          size: 22.sp,
                          color: iconDefaultColor(context),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 2,
              child: Container(
                height: 52.h,
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 2.w,
                      strokeAlign: BorderSide.strokeAlignCenter,
                      color: strokeGrayColor(context),
                    ),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
                child: InkWell(
                  onTap: widget.onCountryTap,
                  child: Row(
                    children: [
                      Text(
                        widget.selectedCountry?.flagEmoji ?? '🏳️',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      Spacer(),
                      Text(
                        widget.selectedCountry != null
                            ? '+${widget.selectedCountry!.phoneCode}'
                            : '+',
                        style: AppTypography.headingColor14(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_dynamicMessage != null)
          Padding(
            padding: EdgeInsets.only(top: 6.h, right: 12.w, left: 12.w),
            child: Row(
              children: [
                Icon(
                  _messageColor == Colors.green
                      ? Icons.check_circle
                      : Icons.error_outline,
                  color: _messageColor,
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    _dynamicMessage!,
                    style: TextStyle(
                      color: _messageColor,
                      fontSize: 12.sp,
                      fontFamily: "ThmanyahSans",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}