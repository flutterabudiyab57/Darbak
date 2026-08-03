import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/api_path.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../../core/router/routes.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
import '../../../../widgets/components/ad_gradient_btn.dart';
import '../../../../widgets/components/appbar.dart';

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
    final locale = AppLocalizations.of(context)!;
    if (otpCode.trim().length < 6) {
      Fluttertoast.showToast(
          msg: locale.enterValidSixDigitOtp,
          textColor: Colors.green,
          fontSize: 14.sp);
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
      Fluttertoast.showToast(
          msg: locale.accountVerifiedSuccessfully,
          textColor: Colors.green,
          fontSize: 14.sp);
      context.pushReplacementNamed(Routes.signin);
    } else {
      try {
        final decoded =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        if (decoded is Map && decoded.containsKey('message')) {
          Fluttertoast.showToast(
              msg: decoded['message'].toString(),
              textColor: Colors.green,
              fontSize: 14.sp);
        } else {
          Fluttertoast.showToast(
              msg: locale.verificationFailedTryAgain,
              textColor: Colors.red,
              fontSize: 14.sp);
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: locale.serverErrorCheckLogs,
            textColor: Colors.red,
            fontSize: 14.sp);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var locale = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: locale.isDirectionRTL(context)
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar:  CustomAppBar(
          title: locale.otpVerification,
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
                    locale.otpCode,
                    style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        locale.enterSixDigitCodeSent,
                        textAlign: TextAlign.center,
                        style:AppTypography.paragraphColor14(context),
                      ),
                      Text(
                        '${widget.phone}',
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
                      locale.verifyNow,
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
                              msg: locale.otpResentSuccessfully,
                              textColor: Colors.green,
                              fontSize: 14.sp);
                        } else {
                          Fluttertoast.showToast(
                              msg: locale.otpResendFailed,
                              textColor: Colors.red,
                              fontSize: 14.sp);
                        }
                      } catch (e) {
                        Fluttertoast.showToast(
                            msg: locale.checkInternetError,
                            textColor: Colors.red,
                            fontSize: 14.sp);
                      }
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            locale.didntReceiveCode,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.045,
                            ),
                          ),
                          Text(
                            locale.resend,
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
