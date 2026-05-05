import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_picker/country_picker.dart';
import '../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../core/helpers/validation/form_validator.dart';
import '../../../../core/style/style.dart';
import '../../../../language/locale.dart';
import '../../../widgets/components/ad_gradient_btn.dart';
import '../../../widgets/components/ad_prim_text_form/DynamicPhoneField_WithCountry.dart';
import '../../../widgets/components/appbar.dart';
import '../../../widgets/components/ad_prim_text_form/ad_prim_text_form.dart';
import '../cubit/complaint_cubit.dart';
import '../cubit/complaint_state.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _descController = TextEditingController();
  Country? selectedCountry;

   String? _phoneError;

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _idNumberController.dispose();
    _descController.dispose();
    super.dispose();
  }

   String? _validatePhone() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final value = _phoneController.text.trim();

    if (value.isEmpty) {
      return isArabic ? 'من فضلك أدخل رقم الهاتف' : 'Please enter phone number';
    }
    if (value.length < 7) {
      return isArabic ? 'رقم الهاتف قصير جداً' : 'Phone number is too short';
    }
    return null;
  }

   String _parseErrorMessage(String rawMessage, bool isArabic) {
    if (rawMessage.contains('302')) {
      return isArabic
          ? 'انتهت الجلسة، يرجى تسجيل الدخول مجدداً'
          : 'Session expired, please login again';
    }
    if (rawMessage.contains('401') || rawMessage.contains('403')) {
      return isArabic ? 'غير مصرح لك بهذا الإجراء' : 'Unauthorized action';
    }
    if (rawMessage.contains('500')) {
      return isArabic ? 'خطأ في الخادم، حاول لاحقاً' : 'Server error, please try again later';
    }
    if (rawMessage.contains('SocketException') || rawMessage.contains('network')) {
      return isArabic ? 'تحقق من اتصالك بالإنترنت' : 'Check your internet connection';
    }
    return isArabic ? 'حدث خطأ، حاول مرة أخرى' : 'Something went wrong, please try again';
  }

  void _submit(BuildContext context) {
    final phoneErr = _validatePhone();
    setState(() => _phoneError = phoneErr);
    final formValid = _formKey.currentState!.validate();

    if (phoneErr != null || !formValid) return;

    final fullPhone =
        '+${selectedCountry?.phoneCode ?? '966'}${_phoneController.text.trim()}';

    context.read<ComplaintCubit>().submitComplaint(
      name: _nameController.text.trim(),
      phone: fullPhone,
      idNumber: _idNumberController.text.trim(),
      description: _descController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;
    final locale = AppLocalizations.of(context);

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: CustomAppBar(
          title: locale!.complaint.toString(),
          showBackButton: true,
          showThemeToggle: true,
        ),
        body: BlocConsumer<ComplaintCubit, ComplaintState>(
          listener: (context, state) {
            if (state is ComplaintSuccess) {
              _nameController.clear();
              _phoneController.clear();
              _idNumberController.clear();
              _descController.clear();
              setState(() => _phoneError = null);
              _formKey.currentState!.reset();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green.shade600,
                  content: Text(
                    isArabic
                        ? '✅ تم إرسال الشكوى بنجاح'
                        : '✅ Complaint sent successfully',
                  ),
                ),
              );
            } else if (state is ComplaintError) {
              final friendlyMsg = _parseErrorMessage(state.message, isArabic);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red.shade600,
                  duration: const Duration(seconds: 4),
                  content: Text('❌ $friendlyMsg'),
                  action: SnackBarAction(
                    label: isArabic ? 'حسناً' : 'OK',
                    textColor: Colors.white,
                    onPressed: () =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ComplaintLoading;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(8.sp),
                  child: Column(
                    spacing: 20.h,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ADPrimTextForm(
                        controller: _nameController,
                        type: TextInputType.text,
                        label: locale.fullName.toString(),
                        pIcon: Icons.person,
                        validat: (value) =>
                        value!.isEmpty ? locale.pleaseEnterName : null,
                        auth: true,
                      ),
                      ADPrimTextForm(
                        controller: _idNumberController,
                        type: TextInputType.number,
                        label: locale.isDirectionRTL(context)
                            ? 'أدخل الهوية الوطنية'
                            : 'Enter National ID',
                        pIcon: Icons.badge,
                        validat: (value) =>
                            FormValidator.numValidate(context, value),
                      ),

                      // ─── Phone widget unchanged + error shown below it ──────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DynamicPhoneFieldWithCountry(
                            controller: _phoneController,
                            selectedCountry: selectedCountry,
                            onCountryTap: () {
                              showCountryPicker(
                                context: context,
                                showPhoneCode: true,
                                onSelect: (Country country) {
                                  setState(() {
                                    selectedCountry = country;
                                    _phoneError = null; // clear on country change
                                  });
                                },
                              );
                            },
                          ),
                          if (_phoneError != null)
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 4.h, right: 12.w, left: 12.w),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red, size: 14.sp),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _phoneError!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12.sp,
                                      fontFamily: "IBMPlexSansArabic",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      Text(
                        locale.complaint.toString(),
                        style: AppTypography.headingColor18(context),
                      ),
                      ADPrimTextForm(
                        controller: _descController,
                        type: TextInputType.multiline,
                        label: isArabic ? 'وصف الشكوى' : 'Complaint description',
                        pIcon: Icons.description,
                        maxlenth: null,
                        validat: (value) => value!.isEmpty
                            ? (isArabic
                            ? 'من فضلك أدخل الشكوى'
                            : 'Please enter the complaint')
                            : null,
                        auth: true,
                      ),
                      isLoading
                          ? const Center(child: LoadingIndicator())
                          : GestureDetector(
                        onTap: () => _submit(context),
                        child: ADGradientButton(locale.submit),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}