import 'dart:ui';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/constants/langCode.dart';
import '../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
import '../../../../widgets/components/ad_gradient_btn.dart';
import '../../../../widgets/components/ad_prim_text_form/DynamicPhoneField_WithCountry.dart';
import '../bloc/forget_password.state.dart';
import '../bloc/forget_password_cubit.dart';
import '../page/enter_code.dart';
import 'package:darbak/service_locator.dart';


class ForgotPasswordScreen extends StatefulWidget {
  static Widget entry() => BlocProvider<ForgetPasswordCubit>(
        create: (_) => sl<ForgetPasswordCubit>(),
        child: ForgotPasswordScreen(),
      );

  @override
  State<StatefulWidget> createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  final phoneController = TextEditingController();
  Country? selectedCountry;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 450),
    );
    scaleAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.elasticInOut,
    );

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
    selectedCountry = Country(
      phoneCode: '966',
      countryCode: 'SA',
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: 'Saudi Arabia',
      example: '512345678',
      displayName: 'Saudi Arabia',
      displayNameNoCountryCode: 'Saudi Arabia',
      e164Key: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: size.height * 0.4 + keyboardHeight,
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
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
            listener: (context, state) {
              if (state is ForgetPassWordError) {
                Fluttertoast.showToast(
                  msg: locale.checkMobileNumber,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.sp,
                );
              }
              if (state is ForgetPasswordLoaded) {
                final cubit = context.read<ForgetPasswordCubit>();
                showModalBottomSheet(
                  useRootNavigator: true,
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  enableDrag: true,
                  backgroundColor: Colors.transparent,
                  constraints: BoxConstraints(
                    maxWidth: double.infinity,
                    maxHeight: MediaQuery.of(context).size.height * 0.95,
                  ),
                  builder: (_) => BlocProvider<ForgetPasswordCubit>.value(
                    value: cubit,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: FractionallySizedBox(
                        child: EnterCodeScrean(),
                      ),
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: false,
                body: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ──────────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              locale.resetPassword.toString(),
                              style: AppTypography.headingColor20(context),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Row(
                                children: [
                                  Text(
                                    locale.goBack.toString(),
                                    style: AppTypography.mainTypographyColor20(
                                        context),
                                  ),
                                  SizedBox(width: 6.w),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 25.sp,
                                    color: strokeMainColor(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10.h),

                        // ── Description ─────────────────────────────────────
                        Text(
                          locale.forgetPasswordDescription,
                          textAlign: TextAlign.right,
                          style: AppTypography.paragraphColor18(context),
                        ),

                        SizedBox(height: 20.h),

                        // ── Phone Field with Country Picker ──────────────────
                        DynamicPhoneFieldWithCountry(
                          controller: phoneController,
                          selectedCountry: selectedCountry,
                          onCountryTap: () {
                            showCountryPicker(
                              context: context,
                              showPhoneCode: true,
                              onSelect: (Country country) {
                                setState(() {
                                  selectedCountry = country;
                                });
                              },
                            );
                          },
                        ),

                        SizedBox(height: 30.h),

                        state is ForgetPasswordLoading
                            ? Center(child: LoadingIndicator())
                            : GestureDetector(
                          onTap: () {
                            BlocProvider.of<ForgetPasswordCubit>(context)
                                .sendPone(phone: phoneController.text);
                            phoneStorage = phoneController.text;
                          },
                          child: ADGradientButton(
                            locale.send.toString(),
                        )
                        ),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    controller.dispose();
    super.dispose();
  }
}