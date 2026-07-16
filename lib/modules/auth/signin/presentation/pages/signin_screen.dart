import 'dart:ui';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:country_picker/country_picker.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../../core/helpers/validation/form_validator.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
import '../../../../../service_locator.dart';
import '../../../../home/all_bookings/presentaion/bloc/allbooking_cubit.dart';
import '../../../../home/profile/blocs/profile_cubit/profile_cubit.dart';
import '../../../../widgets/components/ad_gradient_btn.dart';
import '../../../../widgets/components/ad_prim_text_form/DynamicPhoneField_WithCountry.dart';
import '../../../../widgets/components/ad_prim_text_form/ad_prim_text_form.dart';
import '../../../../widgets/components/identity_type_selector.dart';
import '../../../blocs/auth_bloc/onboarding_cubt_cubit.dart';
import '../../../forgotPassword/presentaion/widgets/forgotPassword.dart';
import '../../../register/presentaion/pages/otp_register.dart';
import '../../../register/presentaion/pages/register_page.dart';
import '../bloc/signin_bloc.dart';
class SignInScreen extends StatefulWidget {
  final Function()? isLogin;
  final OnBoardingCubit? cubit;
  final bool pushAddition;

  const SignInScreen({
    Key? key,
    this.isLogin,
    this.cubit,
    this.pushAddition = false,
  }) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _selectedLoginType = 0;
  Country? selectedCountry;
  late List<IdentityTypeOption> _loginOptions;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AllBookingCubit>(context).booking = null;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeLoginOptions();
  }

  void _initializeLoginOptions() {
    final locale = AppLocalizations.of(context)!;

    _loginOptions = [
      IdentityTypeOption(
        label: locale.email,
        icon: Icons.email_outlined,
        inputType: TextInputType.emailAddress,
        validator: FormValidator.emailValidate,
      ),
      IdentityTypeOption(
        label: locale.phone,
        icon: Icons.phone,
        inputType: TextInputType.phone,
        validator: _validatePhone,
      ),
      IdentityTypeOption(
        label: locale.id,
        icon: Icons.badge,
        inputType: TextInputType.number,
        validator: FormValidator.numValidate,
      ),
    ];
  }

  String? _validatePhone(BuildContext context, String? value) {
    final locale = AppLocalizations.of(context)!;

    if (value == null || value.isEmpty) {
      return locale.thisFieldIsRequired;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return locale.pleaseEnterNumbersOnly;
    }

    if (value.length < 9 || value.length > 15) {
      return locale.invalidPhoneNumber;
    }

    return null;
  }

  String _getLoginLabel() {
    final locale = AppLocalizations.of(context)!;

    switch (_selectedLoginType) {
      case 0:
        return locale.emailAddress!;
      case 1:
        return locale.phoneNumber;
      case 2:
        return locale.idNumber;
      default:
        return locale.dataUser.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
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
        child: BlocProvider(
          create: (context) => sl<SignInBloc>(),
          child: BlocConsumer<SignInBloc, SignInState>(
            listener: (context, state) {
              if (state is RegisterRequiresVerification) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtpVerifyScreen(
                      userId: state.userId,
                      phone: state.phone,
                    ),
                  ),
                );
              } else if (state is SignInSuccess) {
                if (_formKey.currentState!.validate()) {
                  if (widget.pushAddition) {
                    context.read<ProfileCubit>().getProfile().then((_) {
                      Navigator.of(context).pop(true);
                    });
                  } else {
                    context.read<ProfileCubit>().getProfile();
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    context.go('/shell?tab=0&skipLogin=true');
                  }
                }
              }
            },
            builder: (context, state) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: false,
                body: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                locale.signIn.toString(),
                                style: AppTypography.mainTypographyColor24(context),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                locale.logInNowAndBookYour,
                                textAlign: TextAlign.right,
                                style: AppTypography.paragraphColor16(context),
                              ),
                              SizedBox(height: 15.h),

                              // Login Type Selection
                              Text(
                                locale.chooseLoginMethod,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: headingColor(context),
                                  fontFamily: "ThmanyahSans",
                                ),
                              ),
                              SizedBox(height: 8.h),

                               IdentityTypeSelector(
                                selectedIndex: _selectedLoginType,
                                options: _loginOptions,
                                onSelectionChanged: (index) {
                                  setState(() {
                                    _selectedLoginType = index;
                                    controllerEmail.clear();
                                  });
                                },
                              ),
                              SizedBox(height: 15.h),

                              // Input Field - Phone or Email/ID
                              if (_selectedLoginType == 1)
                                DynamicPhoneFieldWithCountry(
                                  controller: controllerEmail,
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
                                ) else
                                ADPrimTextForm(
                                  controller: controllerEmail,
                                  type: _loginOptions[_selectedLoginType].inputType,
                                  label: _getLoginLabel(),
                                  pIcon: _loginOptions[_selectedLoginType].icon,
                                  validat: (value) =>
                                      _loginOptions[_selectedLoginType].validator(context, value),
                                  auth: true,
                                ),

                              SizedBox(height: 15.h),
                              ADPrimTextForm(
                                controller: controllerPassword,
                                type: TextInputType.visiblePassword,
                                label: locale.password.toString(),
                                pIcon: Icons.lock,
                                auth: true,
                              ),
                              SizedBox(height: 14.h),
                              if (state is SignInFailure)
                                Text(
                                  locale.checkUsernameAndPassword.toString(),
                                  style: TextStyle(color: Colors.red),
                                )
                              else
                                SizedBox.shrink(),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    enableDrag: true,
                                    backgroundColor: Colors.transparent,
                                    constraints: const BoxConstraints(maxWidth: double.infinity,),
                                    builder: (context) => BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                      child: FractionallySizedBox(
                                          child: ForgotPasswordScreen.entry()),
                                    ),
                                  );
                                },
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    locale.forgetPassword.toString(),
                                    style: AppTypography.mainTypographyColor14(context),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15.h),

                              SizedBox(height: 12.h),

                              state is SignInLoading
                                  ? Center(
                                child: LoadingIndicator()
                              )
                                  : GestureDetector(
                                onTap: () {
                                  _handleLogin(context);
                                  BlocProvider.of<AllBookingCubit>(context)
                                      .getAllBooking(state: 'running');
                                },
                                child:ADGradientButton(
                                  locale.signIn,
                                  textStyle: AppTypography.buttonText20(context),
                                )

                              ),
                              SizedBox(height: 10.h),

                              GestureDetector(
                                onTap: () {
                                  context.go('/shell?tab=0&skipLogin=true');
                                },
                                child: ADGradientButton(
                                  locale.continueAsGuest!,
                                  border: Border.all(
                                    color: const Color(0xFF05658F),
                                    width: 1.5.w,
                                  ),
                                  backgroundColor: Colors.transparent,
                                  textStyle: AppTypography.paragraphColor20(context),
                                ),),
                              SizedBox(height: 10.h),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    locale.dontHaveAccount.toString(),
                                    style: AppTypography.headingColor16(context),
                                  ),
                                  SizedBox(width: 4.w),
                                  Bounce(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        isDismissible: true,
                                        enableDrag: true,
                                        backgroundColor: Colors.transparent,
                                        constraints: const BoxConstraints(maxWidth: double.infinity,),
                                        builder: (context) => BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                          child: FractionallySizedBox(
                                            child: RegisterPage(
                                              onBoardingCubit: null,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      locale.registerNow.toString(),
                                      style: AppTypography.mainTypographyColor16(context),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String loginValue = controllerEmail.text;
      if (_selectedLoginType == 1 && selectedCountry != null) {
        loginValue = controllerEmail.text;
      }

      BlocProvider.of<SignInBloc>(context).add(SignIn(
        email: loginValue,
        password: controllerPassword.text,
      ));
    }
  }

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPassword.dispose();
    super.dispose();
  }
}