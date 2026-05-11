import 'package:darbak/core/helpers/validation/validation.dart';
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/assets/app_colors.dart';

class ADPrimTextForm extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validat;
  final TextInputType type;
  final Function()? onTap;
  final Function(String)? oFS;
  final int? maxlenth;
  final String label;
  final IconData? pIcon;
  final String? pAssetIcon;
  final IconData? sIcon;
  final Function()? sOnTap;
  final bool isClickable;
  final bool auth;
  final String? hint;
  final List<TextInputFormatter>? inputFormatters;
  final double sizeText;
  final TextEditingController? matchWithController;
  final String? notMatchMessage;
  final bool enableDynamicValidation;
  final String? countryCode;

  ADPrimTextForm({
    Key? key,
    required this.controller,
    this.validat,
    required this.type,
    this.onTap,
    this.oFS,
    this.maxlenth,
    required this.label,
    this.pIcon,
    this.pAssetIcon,
    this.sIcon,
    this.sOnTap,
    this.auth = false,
    this.isClickable = true,
    this.hint,
    this.inputFormatters,
    this.sizeText = 16,
    this.enableDynamicValidation = false,
    this.countryCode,
    this.matchWithController,
    this.notMatchMessage,
  }) : super(key: key);

  @override
  State<ADPrimTextForm> createState() => _ADPrimTextFormState();
}

class _ADPrimTextFormState extends State<ADPrimTextForm> {
  late bool isShow;
  String? _dynamicMessage;
  Color _messageColor = Colors.grey;
  final _formKey = GlobalKey<FormFieldState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    isShow = false;
    super.initState();

    if (widget.enableDynamicValidation) {
      widget.controller.addListener(_updateDynamicValidation);
    }
  }

  @override
  void dispose() {
    if (widget.enableDynamicValidation) {
      widget.controller.removeListener(_updateDynamicValidation);
    }
    super.dispose();
  }

  void _updateDynamicValidation() {
    setState(() {
      String value = widget.controller.text;

      if (widget.type == TextInputType.visiblePassword) {
        if (widget.matchWithController != null) {
          if (value.isEmpty) {
            _dynamicMessage = null;
            return;
          }

          if (value != widget.matchWithController!.text) {
            _dynamicMessage =
                widget.notMatchMessage ?? 'كلمة المرور غير متطابقة';
            _messageColor = Colors.red;
          } else {
            _dynamicMessage = '✓ كلمة المرور متطابقة';
            _messageColor = Colors.green;
          }
          return;
        }

        PasswordStrength strength = Validate.checkPasswordStrength(value);
        switch (strength) {
          case PasswordStrength.empty:
            _dynamicMessage = null;
            _messageColor = Colors.grey;
            break;
          case PasswordStrength.weak:
            _dynamicMessage =
                'كلمة المرور ضعيفة - يجب أن تكون 8 أحرف على الأقل';
            _messageColor = Colors.red;
            break;
          case PasswordStrength.strong:
            _dynamicMessage = '✓ كلمة المرور قوية';
            _messageColor = Colors.green;
            break;
        }
      }
    });
  }

  changeVisibility() {
    setState(() {
      isShow = !isShow;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          maxLength: widget.maxlenth,
          inputFormatters: widget.inputFormatters,
          controller: widget.controller,
          validator: widget.validat,
          onTap: () {
            if (_formKey.currentState?.hasError ?? false) {
              setState(() {
                _autovalidateMode = AutovalidateMode.disabled;
              });
              _formKey.currentState?.reset();
            }
            widget.onTap?.call();
          },
          onChanged: (value) {
            if (_autovalidateMode == AutovalidateMode.disabled &&
                value.isNotEmpty) {
              setState(() {
                _autovalidateMode = AutovalidateMode.onUserInteraction;
              });
            }
          },
          enabled: widget.isClickable,
          onFieldSubmitted: widget.oFS,
          obscureText:
              widget.type == TextInputType.visiblePassword ? !isShow : isShow,
          keyboardType: widget.type,
          style: AppTypography.paragraphColor14(context),
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
                color: widget.auth
                    ? (isDark ? Colors.white70 : Colors.red.withOpacity(0.4))
                    : Theme.of(context).colorScheme.error.withOpacity(0.3),
                width: 1.w,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(
                color: widget.auth
                    ? (isDark ? Colors.white70 : Colors.red.withOpacity(0.4))
                    : Theme.of(context).colorScheme.error.withOpacity(0.3),
                width: 1.w,
              ),
            ),
            errorStyle: TextStyle(
              fontSize: 12.sp,
              fontFamily: "IBMPlexSansArabic",
              fontWeight: FontWeight.w500,
              color: widget.auth
                  ? (isDark ? Colors.white70 : Colors.red)
                  : Theme.of(context).colorScheme.error,
            ),
            errorMaxLines: 2,
            fillColor: backgroundColor(context),
            filled: true,
            hintText: widget.hint,
            hintStyle: AppTypography.paragraphColor15(context),
            labelText: widget.label,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            labelStyle: AppTypography.paragraphColor16(context),
            prefixIcon: widget.pAssetIcon != null
                ? Padding(
                    padding: EdgeInsets.all(12.w),
                    child: widget.pAssetIcon!.endsWith('.svg')
                        ? SvgPicture.asset(
                            widget.pAssetIcon!,
                            width: 16.w,
                            height: 12.h,
                            color: iconDefaultColor(context),
                          )
                        : Image.asset(
                            widget.pAssetIcon!,
                            width: 16.w,
                            height: 16.h,
                            color: iconDefaultColor(context),
                          ),
                  )
                : Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Icon(
                      widget.pIcon,
                      color: iconDefaultColor(context),
                      size: 22.sp,
                    ),
                  ),
            suffixIcon: widget.type == TextInputType.visiblePassword
                ? Padding(
                  padding:   EdgeInsets.symmetric(horizontal:  12.w),
                  child: IconButton(
                      onPressed: changeVisibility,
                      icon: Icon(
                        isShow
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: widget.auth
                            ? strokeGrayColor(context)
                            : Theme.of(context).colorScheme.primary,
                        size: 22.sp,
                      ),
                    ),
                )
                : null,
          ),
        ),
        if (widget.enableDynamicValidation && _dynamicMessage != null)
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
                      fontFamily: "IBMPlexSansArabic",
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
