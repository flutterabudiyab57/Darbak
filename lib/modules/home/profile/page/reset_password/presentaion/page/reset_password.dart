import 'package:darbak/core/helpers/helper_fun.dart';
import 'package:darbak/core/helpers/validation/validation.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/profile/page/reset_password/presentaion/bloc/rsete_password_cubit.dart';
import 'package:darbak/modules/home/profile/page/reset_password/presentaion/bloc/rsete_password_state.dart';
import 'package:darbak/modules/home/profile/page/widget/container_tile.dart';
import 'package:darbak/modules/widgets/components/ad_gradient_btn.dart';
import 'package:darbak/modules/widgets/components/ad_prim_text_form/ad_prim_text_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../../core/constants/assets/app_colors.dart';
import '../../../../../../../core/constants/preferences_constants.dart';
import '../../../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../../../../service_locator.dart';
import '../../../../../../widgets/components/appbar.dart';

class ResetPasswordScrean extends StatefulWidget {
  const ResetPasswordScrean({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScrean> createState() => _ResetPasswordScreanState();
}

class _ResetPasswordScreanState extends State<ResetPasswordScrean> {
  final oldPasswordControler = TextEditingController();
  final newPasswordControler = TextEditingController();
  final confirmPasswordControler = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? savedPassword;

  @override
  void initState() {
    super.initState();
    _loadSavedPassword();
  }

  Future<void> _loadSavedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedPassword = prefs.getString(PreferencesConstants.userPassword);
    });
  }
  bool _isPasswordsValid() {
    return oldPasswordControler.text.length >= 8 &&
        newPasswordControler.text.length >= 8 &&
        confirmPasswordControler.text.length >= 8 &&
        newPasswordControler.text == confirmPasswordControler.text;
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor(context),
        appBar:  CustomAppBar(
          title:locale.resetPassword!.toString(),
          showBackButton: true,
          // showThemeToggle: true,
        ),
        body: BlocProvider(
          create: (context) => sl<RsetePasswordCubit>(),
          child: BlocConsumer<RsetePasswordCubit, RsetePasswordState>(
            listener: (context, state) {
              if (state is RsetePassWordError) {
                HelperFunctions.showFlashBar(
                    context: context,
                    title: locale.error.toString(),
                    message: "${state.error}",
                    icon: Icons.info);
              }
              if (state is RsetePasswordLoaded) {
                _updateSavedPassword(newPasswordControler.text);

                HelperFunctions.showFlashBar(
                    context: context,
                    title: locale.done.toString(),
                    message: locale.passwordChanged.toString(),
                    icon: Icons.check);
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            builder: (context, state) {
              return Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding:   EdgeInsets.all(10.sp),
                    child: Form(
                      key: _formKey,
                      child: ContainerTileWidget(widgets: [
                        ADPrimTextForm(
                          auth: true,
                          controller: oldPasswordControler,
                          type: TextInputType.visiblePassword,
                          label: locale.oldPassword.toString(),
                          pIcon: Icons.lock,
                          validat: (value) => Validate.validateOldPassword(
                              context, value, savedPassword),

                        ),
                        SizedBox(height: 20.h),
                        ADPrimTextForm(
                          auth: true,
                          controller: newPasswordControler,
                          type: TextInputType.visiblePassword,
                          label: locale.newPassword.toString(),
                          pIcon: Icons.lock,
                          enableDynamicValidation: true,

                        ),
                        SizedBox(height: 20.h),
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
                        SizedBox(height: 20.h),
                        state is RsetePasswordLoading
                            ? const Center(
                            child: LoadingIndicator()
                        )
                            : InkWell(
                          onTap: () {
                            if (!_isPasswordsValid()) {
                              HelperFunctions.showFlashBar(
                                context: context,
                                title: locale.error.toString(),
                                message: 'كلمة المرور يجب أن تكون 8 أحرف على الأقل ومتطابقة',
                                icon: Icons.info,
                              );
                              return;
                            }

                            if (_formKey.currentState!.validate()) {
                              BlocProvider.of<RsetePasswordCubit>(context).rsetePassword(
                                oldPassWord: oldPasswordControler.text,
                                newPassWord: newPasswordControler.text,
                                confirmPassWord: confirmPasswordControler.text,
                              );
                            }
                          },
                          child: ADGradientButton(
                              locale.changePassword.toString()),
                        ),
                      ]),
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

  Future<void> _updateSavedPassword(String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferencesConstants.userPassword, newPassword);
    setState(() {
      savedPassword = newPassword;
    });
  }
}