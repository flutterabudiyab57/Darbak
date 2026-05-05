import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/api_path.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
import '../../../../widgets/components/ad_gradient_btn.dart';
import '../../../../widgets/components/appbar.dart';
import '../../../signin/presentation/pages/signin_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String userId;
  final String phone;

  const OtpVerifyScreen({required this.userId, required this.phone, Key? key})
      : super(key: key);

  @override
  _OtpVerifyScreenState createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  String otpCode = "";
  bool isLoading = false;

  Future<void> verifyOtp() async {
    if (otpCode.trim().length < 6) {
      Fluttertoast.showToast(msg: 'الرجاء إدخال رمز OTP صحيح مكون من 6 أرقام' ,textColor: Colors.green,
        fontSize: 14.sp,);
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse('$mainApi/register/verify');
    final response = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {
        "user_id": widget.userId,
        "code": otpCode,
      },
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: '✅ تم التحقق من الحساب بنجاح!',textColor: Colors.green,
        fontSize: 14.sp,);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SignInScreen()),
      );
    } else {
      try {
        final decoded =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        if (decoded is Map && decoded.containsKey('message')) {
          Fluttertoast.showToast(msg: decoded['message'].toString(),textColor: Colors.green,
            fontSize: 14.sp,);
        } else {
          Fluttertoast.showToast(msg: '❌ فشل التحقق. حاول مرة أخرى.',textColor: Colors.red,
            fontSize: 14.sp,);
        }
      } catch (e) {
        Fluttertoast.showToast(msg: 'حدث خطأ في السيرفر. تحقق من السجلات.',textColor: Colors.red,
          fontSize: 14.sp,);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var locale = AppLocalizations.of(context)!;
    String t(String arabic, String english) {
      return locale.isDirectionRTL(context) ? arabic : english;
    }

    return Directionality(
      textDirection: locale.isDirectionRTL(context)
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar:  CustomAppBar(
          title: locale.isDirectionRTL(context) ? 'تحقق من OTP' : 'OTP Verification',
          showBackButton: true,
          // showThemeToggle: false,
        ),        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenWidth * 0.1),
                  Icon(Icons.lock_outline,
                      size: screenWidth * 0.2, color: mainTypographyColor(context)),
                  SizedBox(height: screenWidth * 0.05),
                  Text(
                    t('رمز التحقق', 'OTP Code'),
                    style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t('أدخل الرمز المكون من 6 أرقام المرسل إلى ',
                            'Enter the 6-digit code sent to '),
                        textAlign: TextAlign.center,
                        style:AppTypography.paragraphColor14(context),
                      ),
                      Text(
                        t('${widget.phone}', '${widget.phone}'),
                        textAlign: TextAlign.center,
                        style:AppTypography.headingColor16(context),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.05),

                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: OtpTextField(
                      numberOfFields: 6,
                      borderColor: Color(0xFF5E4ECB),
                      showFieldAsBox: true,
                      fieldWidth: screenWidth / 8,
                      onCodeChanged: (code) {},
                      onSubmit: (verificationCode) {
                        setState(() {
                          otpCode = verificationCode;
                        });
                        verifyOtp();
                      },
                    ),
                  ),


                  SizedBox(height: screenWidth * 0.05),
                  isLoading
                      ? LoadingIndicator()
                      :GestureDetector(
                    onTap: verifyOtp,
                    child: ADGradientButton(
                      t('تحقق الآن', 'Verify Now'),
                      width: screenWidth * 0.6,
                    ),
                  )
                  ,
                  SizedBox(height: screenWidth * 0.05),
                  TextButton(
                    onPressed: () async {
                      final url = Uri.parse('$mainApi/register/resend-otp');
                      try {
                        final response = await http.post(
                          url,
                          headers: {"Accept": "application/json"},
                          body: {
                            "user_id": widget.userId,
                          },
                        );

                        if (response.statusCode == 200) {
                          Fluttertoast.showToast(
                              msg: t('✅ تم إعادة إرسال الرمز بنجاح!',
                                  '✅ OTP resent successfully!'),textColor: Colors.green,
                            fontSize: 14.sp,);
                        } else {
                          Fluttertoast.showToast(
                              msg: t('❌ فشل إعادة إرسال الرمز. حاول مرة أخرى.',
                                  '❌ Failed to resend OTP. Try again.'),textColor: Colors.red,
                            fontSize: 14.sp,);
                        }
                      } catch (e) {
                        Fluttertoast.showToast(
                            msg: t('⚠️ حدث خطأ. تحقق من اتصالك بالإنترنت.',
                                '⚠️ Something went wrong. Check your internet.'),textColor: Colors.red,
                          fontSize: 14.sp,);
                      }
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            t('لم تستلم الرمز؟ ', "Didn't receive the code? "),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.045,
                            ),
                          ),
                          Text(
                            t('إعادة الإرسال', " Resend"),
                            style: TextStyle(
                              color: Color(0xFF5E4ECB),
                              fontSize: screenWidth * 0.045,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
