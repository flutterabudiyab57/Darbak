import 'package:darbak/core/style/style.dart';
import 'package:darbak/modules/home/selectLanguage/languageCubit.dart';
import 'package:darbak/language/locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/assets/app_colors.dart';
import '../../../core/helpers/SharedPreference/pereferences.dart';
import '../../widgets/components/ad_gradient_btn.dart';

class SelectLanguage extends StatefulWidget {
  final bool isStart;

  SelectLanguage([this.isStart = false]);

  @override
  _SelectLanguageState createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  late LanguageCubit _languageCubit;
  int? _selectedLanguage = -1;
  String? token;

  @override
  void initState() {
    super.initState();
    _languageCubit = BlocProvider.of<LanguageCubit>(context);
    _loadToken();
  }

  Future<void> _loadToken() async {
    token = await SharedPreferencesHelper().get("token");
    setState(() {});
  }
  bool en_Selected = false;
  bool ar_Selected = false;
  int? group;

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * 0.10,
              ),
              Image.asset("assets/images/selc_language.png"),
              SizedBox(height: size.height * 0.07,),
              Text(locale.welcomeToDarbak,
                  style: AppTypography.headingColor26(context)
              ),
              SizedBox(
                height: size.height * 0.010,
              ),
              Text(locale.chooseYourLanguage,
                textAlign: TextAlign.center,
                  style: AppTypography.paragraphColor20(context)
              ),
              SizedBox(
                height: size.height * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      ar_Selected = false;
                      en_Selected == false
                          ? en_Selected = true
                          : en_Selected = false;
                      _selectedLanguage = 0;
                      setState(() {
                        en_Selected == false ? _selectedLanguage = -1 : false;
                      });
                    },
                    child: Container(
                      width: 145.w,
                      height: 55.h,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: en_Selected == true
                                  ? strokeMainColor(context)
                                  :   strokeGrayColor(context),
                              width: 2.w),
                          borderRadius: BorderRadius.circular(24.sp),
                          color: en_Selected == true
                              ? buttonSecondaryColor(context)
                              : Colors.transparent),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SvgPicture.asset('assets/icons/england.svg',height: 26.h,
                            width: 26.w,),
                          Text(
                            'English',
                            style:AppTypography.headingColor16(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      en_Selected = false;
                      ar_Selected == false
                          ? ar_Selected = true
                          : ar_Selected = false;
                      _selectedLanguage = 1;
                      setState(() {
                        ar_Selected == false ? _selectedLanguage = -1 : false;
                      });
                    },
                    child: Container(
                      width: 145.w,
                      height: 55.h,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: ar_Selected == true
                                  ? strokeMainColor(context)
                            :   strokeGrayColor(context),
                              width: 2.w),
                          borderRadius: BorderRadius.circular(24.sp),
                          color: ar_Selected == true
                              ? buttonPrimaryBgColor(context)
                              : Colors.transparent),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SvgPicture.asset('assets/icons/Flags.svg',height: 26.h,
                            width: 26.w,),
                          Text(
                            'العربية',
                            style:AppTypography.headingColor16(context),

                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: size.height * 0.03,),
              SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: () async {
                    await SharedPreferencesHelper().set("isLanguageSelected", "true");

                    if (_selectedLanguage == 0 && en_Selected == true) {
                      _languageCubit.selectEngLanguage();
                    } else if (_selectedLanguage == 1 && ar_Selected == true) {
                      _languageCubit.selectArabicLanguage();
                    }

                    if (widget.isStart) {
                      context.go(token != null ? '/home' : '/onboarding');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                    child:ADGradientButton(
                      locale.confirm,
                      height: 56.h,
                      textStyle: AppTypography.buttonText20(context),
                    )

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}