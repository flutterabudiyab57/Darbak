import 'package:country_picker/country_picker.dart';
import 'package:bounce/bounce.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../../core/helpers/validation/form_validator.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
import '../../../../../service_locator.dart';
import '../../../../home/profile/page/privacy_policy/privacy_policy.dart';
import '../../../../widgets/components/ad_gradient_btn.dart';
import '../../../../widgets/components/ad_prim_text_form/DynamicPhoneField_WithCountry.dart';
import '../../../../widgets/components/ad_prim_text_form/ad_prim_text_form.dart';
import '../../../../widgets/components/identity_type_selector.dart';
import '../../../blocs/auth_bloc/onboarding_cubt_cubit.dart';
import '../../../forgotPassword/presentaion/widgets/forgotPassword.dart';
import '../../../signin/presentation/pages/signin_screen.dart';
import '../bloc/register_cubit.dart';
import 'otp_register.dart';

class RegisterPage extends StatefulWidget {
  final Function()? isLogin;
  final OnBoardingCubit? onBoardingCubit;
  final bool pushAddition;

  const RegisterPage({
    Key? key,
    this.isLogin,
    this.onBoardingCubit,
    this.pushAddition = false,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final idNumberController = TextEditingController();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Country? selectedCountry;
  bool _isAgreeTerms = false;
  int _selectedCard = 0;
  TextInputType selectedInputType = TextInputType.number;

  String? _dynamicValidationMessage;
  Color _validationMessageColor = Colors.grey;

  late List<IdentityTypeOption> _identityOptions;

  @override
  void initState() {
    super.initState();
    _initializeCountry();
    idNumberController.addListener(_updateDynamicValidation);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeIdentityOptions();
  }

  void _initializeCountry() {
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

  void _initializeIdentityOptions() {
    final locale = AppLocalizations.of(context)!;
    _identityOptions = [
      IdentityTypeOption(
        label: locale.nationalId,
        icon: Icons.badge,
        inputType: TextInputType.number,
        validator: (ctx, val) => FormValidator.numValidate(ctx, val),
      ),
      IdentityTypeOption(
        label: locale.iqama,
        icon: Icons.badge,
        inputType: TextInputType.number,
        validator: (ctx, val) => FormValidator.numVisitValidate(ctx, val),
      ),
      IdentityTypeOption(
        label: locale.passport,
        icon: Icons.travel_explore,
        inputType: TextInputType.text,
        validator: (ctx, val) => _specialCharValidate(ctx, val),
      ),
    ];
  }

  void _updateDynamicValidation() {
    setState(() {
      String value = idNumberController.text;
      var locale = AppLocalizations.of(context)!;

      if (value.isEmpty) {
        _dynamicValidationMessage = null;
        return;
      }

      switch (_selectedCard) {
        case 0:
          _validateNationalID(value, locale);
          break;
        case 1:
          _validateIqama(value, locale);
          break;
        case 2:
          _validatePassport(value, locale);
          break;
      }
    });
  }

  void _validateNationalID(String value, AppLocalizations locale) {
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      _dynamicValidationMessage = locale.pleaseEnterNumbersOnly;
      _validationMessageColor = Colors.red;
    } else if (value.length < 10) {
      _dynamicValidationMessage = locale.mustBe10DigitsValueLength;
      _validationMessageColor = Colors.orange;
    } else if (value.length == 10 && value.startsWith('1')) {
      _dynamicValidationMessage = locale.validNationalId;
      _validationMessageColor = Colors.green;
    } else if (value.length == 10 && !value.startsWith('1')) {
      _dynamicValidationMessage = locale.idMustStartWith1;
      _validationMessageColor = Colors.red;
    } else {
      _dynamicValidationMessage = locale.invalidIdNumber;
      _validationMessageColor = Colors.red;
    }
  }

  void _validateIqama(String value, AppLocalizations locale) {
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      _dynamicValidationMessage = locale.pleaseEnterNumbersOnly;
      _validationMessageColor = Colors.red;
    } else if (value.length < 10) {
      _dynamicValidationMessage = locale.mustBe10DigitsValueLength;
      _validationMessageColor = Colors.orange;
    } else if (value.length == 10 && value.startsWith('2')) {
      _dynamicValidationMessage = locale.validIqamaNumber;
      _validationMessageColor = Colors.green;
    } else if (value.length == 10 && !value.startsWith('2')) {
      _dynamicValidationMessage = locale.iqamaMustStartWith2;
      _validationMessageColor = Colors.red;
    } else {
      _dynamicValidationMessage = locale.invalidIqamaNumber;
      _validationMessageColor = Colors.red;
    }
  }

  void _validatePassport(String value, AppLocalizations locale) {
    String pattern = r'^(?!^0+$)[a-zA-Z0-9]{3,15}$';
    RegExp regExp = RegExp(pattern);

    if (value.length < 6) {
      _dynamicValidationMessage = locale.mustBeAtLeast6Characters;
      _validationMessageColor = Colors.orange;
    } else if (regExp.hasMatch(value)) {
      _dynamicValidationMessage = locale.validPassportNumber;
      _validationMessageColor = Colors.green;
    } else {
      _dynamicValidationMessage = locale.mustContainOnlyLettersAndNumbers;
      _validationMessageColor = Colors.red;
    }
  }

  String _getLabelText(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    switch (_selectedCard) {
      case 0:
        return locale.enterNationalId;
      case 1:
        return locale.enterIqamaNumber;
      case 2:
        return locale.enterPassportNumber;
      default:
        return locale.enterIdAndNumber.toString();
    }
  }

  IconData _getIconData() {
    switch (_selectedCard) {
      case 0:
      case 1:
        return Icons.badge;
      case 2:
        return Icons.travel_explore;
      default:
        return Icons.wallet;
    }
  }

  String? _validateInput(BuildContext context, String? value) {
    switch (_selectedCard) {
      case 0:
        return FormValidator.numValidate(context, value);
      case 1:
        return FormValidator.numVisitValidate(context, value);
      case 2:
        return _specialCharValidate(context, value);
      default:
        return null;
    }
  }

  String? _specialCharValidate(BuildContext context, String? value) {
    var locale = AppLocalizations.of(context)!;

    if (value == null || value.isEmpty) {
      return locale.pleaseEnterThePassportNumber;
    }

    String pattern = r'^(?!^0+$)[a-zA-Z0-9]{3,15}$';
    RegExp regExp = RegExp(pattern);

    if (!regExp.hasMatch(value)) {
      return locale.mustBe3To15Letters;
    }

    return null;
  }


  void _handleRegisterError(RegisterError state, AppLocalizations locale) {
    String errorString = state.massage.toString();
    bool containsEmailError = errorString.contains('email');
    bool containsPhoneError = errorString.contains('phone');
    bool containsIdNumberError = errorString.contains('id_number');

    final Map<String, String> errorMessages = {
      'emailPhoneId': locale.emailPhoneAndIdNumberAre,
      'emailPhone': locale.emailAndPhoneAreAlreadyTaken,
      'emailId': locale.emailAndIdNumberAreAlready,
      'phoneId': locale.phoneAndIdNumberAreAlready,
      'email': locale.emailIsAlreadyTaken,
      'phone': locale.phoneIsAlreadyTaken,
      'id': locale.idNumberIsAlreadyTaken,
    };

    String key = '';
    if (containsEmailError) key += 'email';
    if (containsPhoneError) key += (key.isNotEmpty ? 'Phone' : 'phone');
    if (containsIdNumberError) key += (key.isNotEmpty ? 'Id' : 'id');

    String errorMessage = errorMessages[key] ??
        (locale.registerFailedPleaseTryAgain);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 100.h,
            child: Padding(
              padding: EdgeInsets.all(8.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: const Color(0xffD62E2E), size: 28.sp),
                  SizedBox(height: 10.h),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.redAccent.shade200,
                      fontWeight: FontWeight.w500,
                      fontSize: 13.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: const Color(0xffffffff),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    locale.close,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      isDismissible: true,
                      enableDrag: true,
                      backgroundColor: Colors.transparent,
                      constraints: BoxConstraints(
                        maxWidth: double.infinity,
                        maxHeight: MediaQuery.of(context).size.height * 0.85,
                      ),
                      builder: (context) => BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: FractionallySizedBox(
                          child: ForgotPasswordScreen(),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    locale.forgetPassword2,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var locale = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25.r),
        topRight: Radius.circular(25.r),
      ),
      child: BlocProvider<RegisterCubit>(
        create: (context) => sl<RegisterCubit>(),
        child: BlocConsumer<RegisterCubit, RegisterState>(
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
            } else if (state is RegisterSuccess) {
              widget.pushAddition
                  ? Navigator.of(context).pop(true)
                  : Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => SignInScreen(),
                ),
                ModalRoute.withName('/'),
              );

              Fluttertoast.showToast(
                msg: locale.accountHasBeenCreatedSuccessfully,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: const Color(0xff327B5B),
                textColor: Colors.white,
                fontSize: 14.sp,
              );
            } else if (state is RegisterError) {
              _handleRegisterError(state, locale);
            }
          },
          builder: (context, state) {
            var cubit = RegisterCubit.get(context);
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                backgroundColor: backgroundColor(context),
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  toolbarHeight: 70.hs(context),
                  backgroundColor: backgroundColor(context),
                  title: Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: Text(
                      locale.welcomeAtAbudiyab.toString(),
                      style: AppTypography.mainTypographyColor24(context),
                    ),
                  ),
                ),
                body: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.h),
                          Text(
                            locale.openYourAccountNowAndBook,
                            style: AppTypography.paragraphColor16(context),
                          ),
                          SizedBox(height: 12.h),

                          ADPrimTextForm(
                            controller: userNameController,
                            type: TextInputType.text,
                            label: locale.fullUserName,
                            pIcon: Icons.person,
                            validat: (value) => FormValidator.nameValidate(context, value),
                            auth: true,
                          ),
                          SizedBox(height: 10.h),

                          ADPrimTextForm(
                            controller: emailController,
                            type: TextInputType.emailAddress,
                            label: locale.emailAddress.toString(),
                            pIcon: Icons.email,
                            validat: (value) => FormValidator.emailValidate(context, value),
                            auth: true,
                          ),
                          SizedBox(height: 10.h),

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
                          SizedBox(height: 10.h),

                          ADPrimTextForm(
                            controller: passwordController,
                            type: TextInputType.visiblePassword,
                            label: locale.password.toString(),
                            pIcon: Icons.lock,
                            auth: true,
                            enableDynamicValidation: true,
                          ),
                          SizedBox(height: 10.h),

                          ADPrimTextForm(
                            controller: confirmPasswordController,
                            type: TextInputType.visiblePassword,
                            label: locale.confirmPassword.toString(),
                            pIcon: Icons.lock,
                            auth: true,
                            enableDynamicValidation: true,
                            matchWithController: passwordController,
                            notMatchMessage: locale.passwordsDoNotMatch,
                          ),
                          SizedBox(height: 14.h),

                          Text(
                            locale.identityType,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: headingColor(context),
                              fontFamily: "IBMPlexSansArabic",
                            ),
                          ),
                          SizedBox(height: 8.h),

                          IdentityTypeSelector(
                            selectedIndex: _selectedCard,
                            options: _identityOptions,
                            onSelectionChanged: (index) {
                              setState(() {
                                _selectedCard = index;
                                idNumberController.clear();
                                _dynamicValidationMessage = null;
                                selectedInputType = (_selectedCard == 2)
                                    ? TextInputType.text
                                    : TextInputType.number;
                              });
                            },
                          ),
                          SizedBox(height: 10.h),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ADPrimTextForm(
                                controller: idNumberController,
                                type: selectedInputType,
                                label: _getLabelText(context),
                                pIcon: _getIconData(),
                                validat: (value) => _validateInput(context, value),
                                auth: true,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),

                          Bounce(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    content: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                cubit.getImage("camera").then((value) {
                                                  Navigator.pop(context);
                                                });
                                              },
                                              icon: Icon(
                                                Icons.camera_alt,
                                                color: iconDefaultColor(context),
                                              ),
                                              iconSize: 36.sp,
                                            ),
                                            Text(
                                              locale.tackPhoto.toString(),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                cubit.getImage("gallery").then((value) {
                                                  Navigator.pop(context);
                                                });
                                              },
                                              icon: Icon(
                                                Icons.image,
                                                color: iconDefaultColor(context),
                                              ),
                                              iconSize: 36.sp,
                                            ),
                                            Text(
                                              locale.gallery.toString(),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: 52.h,
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1.5.w,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: strokeGrayColor(context),
                                  ),
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // FaIcon(
                                  //   FontAwesomeIcons.upload,
                                  //   color: iconDefaultColor(context),
                                  //   size: 18.sp,
                                  // ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      cubit.imagePathFace == ""
                                          ? locale.uploadLicense.toString()
                                          : locale.uploadedSuccessfully.toString(),
                                      style: AppTypography.paragraphColor15(context),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (cubit.imagePathFace != "")
                                    Icon(
                                      Icons.check_circle_outline_outlined,
                                      color: iconDefaultColor(context),
                                      size: 18.sp,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Theme(
                                data: ThemeData(
                                  primarySwatch: Colors.grey,
                                  unselectedWidgetColor:
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                                child: Transform.scale(
                                  scale: 0.8,
                                  child: Checkbox(
                                    value: _isAgreeTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        _isAgreeTerms = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Bounce(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PrivacyPolicyScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    locale.agreeTermsAndConditions.toString(),
                                    style: AppTypography.paragraphColor14(context),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),

                          state is RegisterLoading
                              ? const Center(child: LoadingIndicator())
                              : Center(
                            child: GestureDetector(
                              onTap: () async {
                                final facebookAppEvents = FacebookAppEvents();
                                await facebookAppEvents.logCompletedRegistration();
                                await facebookAppEvents.flush();

                                if (_formKey.currentState!.validate() &&
                                    _isAgreeTerms &&
                                    cubit.imagePathFace.isNotEmpty) {
                                  cubit.userRegister(
                                    idNumber: idNumberController.text,
                                    name: userNameController.text,
                                    email: emailController.text,
                                    phone: phoneController.text,
                                    password: passwordController.text,
                                    passworConfirm: confirmPasswordController.text,
                                    licenceFace: cubit.imagePathFace,
                                    country_key: selectedCountry!.phoneCode,
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          locale.pleaseEnsureAllFieldsAreFilled,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: Colors.black,
                                          ),
                                        ),
                                        backgroundColor: Colors.white,
                                      );
                                    },
                                  );
                                }
                              },
                              child: ADGradientButton(
                                locale.register,
                                width: size.width * 0.85,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                locale.alreadyHaveAccount.toString(),
                                style: AppTypography.headingColor16(context),
                              ),
                              SizedBox(width: 5.w),
                              Bounce(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    enableDrag: true,
                                    backgroundColor: Colors.transparent,
                                    constraints: BoxConstraints(
                                      maxWidth: double.infinity,
                                      maxHeight: size.height * 0.85,
                                    ),
                                    builder: (context) => BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                      child: FractionallySizedBox(
                                        child: SignInScreen(pushAddition: true),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  locale.signIn.toString(),
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    idNumberController.removeListener(_updateDynamicValidation);
    idNumberController.dispose();
    userNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}