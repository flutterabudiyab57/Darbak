import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/helpers/helper_fun.dart';
import '../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
import '../../../../widgets/components/ad_gradient_btn.dart';
import '../bloc/forget_password.state.dart';
import '../bloc/forget_password_cubit.dart';
import 'change_password.dart';


class EnterCodeScrean extends StatefulWidget {
  EnterCodeScrean({Key? key}) : super(key: key);

  @override
  State<EnterCodeScrean> createState() => _EnterCodeScreanState();
}

class _EnterCodeScreanState extends State<EnterCodeScrean> {
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String getCode() {
    return _controllers.map((c) => c.text).join();
  }

  Widget buildCodeInputBoxes() {
    final isRTL = AppLocalizations.of(context)!.isDirectionRTL(context);

    final boxList = List.generate(4, (index) {
      return Container(
        width: 70.w,
        height: 68.h,
        margin: EdgeInsets.symmetric(horizontal: 10.w,),
        decoration: BoxDecoration(
          color: buttonWhiteColor(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: strokeGrayColor(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.light
                  ? Color(0xFF0A708D)
                  : Color(0xFF00A0FF),
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            },
          ),
        ),
      );
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: isRTL ? boxList.reversed.toList() : boxList,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: size.height * 0.45 + keyboardHeight,
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
              if (state is CodeError) {
                HelperFunctions.showFlashBar(
                  context: context,
                  title: locale!.error.toString(),
                  message: locale.oldCustCode.toString(),
                  icon: Icons.info,
                );
              }
              if (state is CodeLoaded) {
                final cubit = context.read<ForgetPasswordCubit>();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  enableDrag: true,
                  backgroundColor: Colors.transparent,
                  constraints: BoxConstraints(
                    maxWidth: double.infinity,
                    // maxHeight: MediaQuery.of(context).size.height * 0.95,
                  ),                          builder: (_) => BlocProvider<ForgetPasswordCubit>.value(
                    value: cubit,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: FractionallySizedBox(
                        child: ChangePasswordScreen(),
                      ),
                    ),
                  ),
                );
              }            },
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
                        SizedBox(height: 12.h),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Text(
                               locale!.enterCodeSent.toString(),
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
                            Text(
                              locale.copyCode.toString(),
                              style: AppTypography.paragraphColor18(context),
                            ),
                            SizedBox(height: 10.h),
                            // Padding(
                            //   padding: EdgeInsets.all(8.sp),
                            //   child: Center(
                            //     child: Image.asset(
                            //       "assets/images/rePass2.png",
                            //       fit: BoxFit.cover,
                            //       width: 260.w,
                            //       height: 230.h,
                            //     ),
                            //   ),
                            // ),
                            SizedBox(height: 10.h),
                            buildCodeInputBoxes(),
                            SizedBox(height: 30.h),
                            state is CodeLoading
                                ? Center(
                                child: LoadingIndicator()

                            )
                                : GestureDetector(
                              onTap: () {
                                final code = getCode();
                                if (code.length < 4) {
                                  HelperFunctions.showFlashBar(
                                    context: context,
                                    title: locale.error.toString(),
                                    message: locale.pleaseEnter4DigitCode,
                                    icon: Icons.error,
                                  );
                                  return;
                                }
                                print('الكود اللي المستخدم كتبه: $code');
                                BlocProvider.of<ForgetPasswordCubit>(context)
                                    .sendCode(code: code);
                              },
                              child:  ADGradientButton(
                                locale.send.toString(),
                )
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