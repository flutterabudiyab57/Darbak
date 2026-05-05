import 'dart:ui';
import 'package:darbak/modules/auth/forgotPassword/presentaion/page/successPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/constants/langCode.dart';
import '../../../../../core/constants/preferences_constants.dart';
import '../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
import '../../../../widgets/components/ad_prim_text_form/ad_prim_text_form.dart';
import '../bloc/forget_password.state.dart';
import '../bloc/forget_password_cubit.dart';


class ChangePasswordScreen extends StatefulWidget {
  ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final newPasswordControler = TextEditingController();
  final confirmPasswordControler = TextEditingController();

  @override
  void dispose() {
    newPasswordControler.dispose();
    confirmPasswordControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: size.height * 0.75 + keyboardHeight,
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
              if (state is ChangePassWordError) {
                Fluttertoast.showToast(
                  msg: locale!.isDirectionRTL(context)
                      ? 'تأكد من كلمة المرور الجديدة الخاصة بك'
                      : 'Make sure your new password.',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Color(0xffaf3636),
                  textColor: Colors.white,
                  fontSize: 14.sp,
                );
              }
              if (state is ChangePasswordLoaded) {
                _updateSavedPassword(newPasswordControler.text);

                Navigator.of(context).popUntil((route) => route.isFirst);

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  enableDrag: true,
                  backgroundColor: Colors.transparent,
                  constraints: BoxConstraints(
                    maxWidth: double.infinity,
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),                          builder: (context) => BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: FractionallySizedBox(
                      child: SuccessBottomSheet(),
                    ),
                  ),
                );
                phoneStorage = null;
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
                    padding: EdgeInsets.symmetric(horizontal: 14.w,vertical: 30.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              locale!.newPass.toString(),
                              style: AppTypography.headingColor20(context),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Row(
                                children: [
                                  Text(
                                    locale.goBack.toString(),
                                    style: AppTypography.mainTypographyColor20(context),

                                  ),
                                  SizedBox(width :6.w),
                                  Icon(Icons.arrow_forward_ios,size: 25.sp,color: strokeMainColor(context),)
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Center(
                            //   child: Image.asset(
                            //     "assets/images/rePass3.png",
                            //     fit: BoxFit.cover,
                            //     width: 300.w,
                            //     height: 230.h,
                            //   ),
                            // ),
                            // SizedBox(height: 20.h),
                            ADPrimTextForm(
                              auth: true,
                              controller: newPasswordControler,
                              type: TextInputType.visiblePassword,
                              label: locale.newPassword.toString(),
                              pIcon: Icons.lock,
                              enableDynamicValidation: true,
                            ),
                            SizedBox(height: 15.h),
                            ADPrimTextForm(
                              controller: confirmPasswordControler,
                              type: TextInputType.visiblePassword,
                              label: locale.confirmPassword.toString(),
                              pIcon: Icons.lock,
                              auth: true,
                              enableDynamicValidation: true,
                              matchWithController: newPasswordControler,
                              notMatchMessage: 'كلمة المرور غير متطابقة',
                            ),
                            SizedBox(height: 30.h),
                            state is ChangePasswordLoading
                                ? Center(
                                child: LoadingIndicator()

                            )
                                : GestureDetector(
                              onTap: () {
                                BlocProvider.of<ForgetPasswordCubit>(context)
                                    .passwordchange(
                                  password: newPasswordControler.text,
                                  confirmPassword: confirmPasswordControler.text,
                                );
                              },
                              child: Container(
                                height: 50.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.r),
                                  color: buttonPrimaryBgColor(context),
                                ),
                                child: Center(
                                  child: Text(
                                    locale.changePassword.toString(),
                                    style: AppTypography.buttonText20(context),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
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
}

Future<void> _updateSavedPassword(String newPassword) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(PreferencesConstants.userPassword, newPassword);
}