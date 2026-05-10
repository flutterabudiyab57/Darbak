import 'dart:developer';
import 'dart:io';

import 'package:bounce/bounce.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:widget_zoom/widget_zoom.dart';

import '../../../../../../../core/constants/assets/app_colors.dart';
 import '../../../../../../../core/helpers/helper/Network_error_widget.dart';
import '../../../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../../../../core/helpers/validation/validation.dart';
import '../../../../../../../language/locale.dart';
import '../../../../../../../service_locator.dart';
import '../../../../../../widgets/components/ad_gradient_btn.dart';
import '../../../../../../widgets/components/ad_prim_text_form/ad_prim_text_form.dart';
import '../../../../../../widgets/components/appbar.dart';
import '../../../../../search_screen/presentaion/widget/shimmer_list.dart';
import '../../../../blocs/profile_cubit/profile_cubit.dart';
import '../../../reset_password/presentaion/page/reset_password.dart';
import '../../../widget/container_tile.dart';
import '../bloc/edit_profile_cubit.dart';
import '../bloc/edit_profile_state.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor(context),
        appBar: CustomAppBar(
          title: locale.editProfile!.toString(),
          showBackButton: true,
          // showThemeToggle: true,
        ),
        body: BlocProvider(
          create: (context) => sl<EditProfileCubit>(),
          child: _EditProfileContent(),
        ),
      ),
    );
  }
}

class _EditProfileContent extends StatefulWidget {

  const _EditProfileContent({Key? key}) : super(key: key);

  @override
  State<_EditProfileContent> createState() => _EditProfileContentState();
}

class _EditProfileContentState extends State<_EditProfileContent> {
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasConnection = connectivityResult != ConnectivityResult.none;

    if (!hasConnection) {
      Fluttertoast.showToast(
        msg: "لا يوجد اتصال بالإنترنت",
        backgroundColor: const Color(0xffF6A9A9),
        textColor: Colors.red,
      fontSize: 14.sp,
      );
      return;
    }

    if (mounted) {
      BlocProvider.of<ProfileCubit>(context).getProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        final locale = AppLocalizations.of(context)!;
        if (profileState is ProfileLoading) {
          return Center(child: ShimmerLoadingList(itemCount: 4));
        }

         if (profileState is ProfileSuccess) {
          return _EditProfileForm(
            profileModel: profileState.profileModel,
          );
        }

        if (profileState is ProfileFailed) {
          return NetworkErrorWidget(onRetry: _loadProfileData);
        }
        return Center(
          child: ElevatedButton(
            onPressed: _loadProfileData,
            child: Text("تحميل البيانات"),
          ),
        );
      },
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  final dynamic profileModel;

  const _EditProfileForm({required this.profileModel});

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  late final TextEditingController nameControler;
  late final TextEditingController emailControler;
  late final TextEditingController phoneControler;
  late final TextEditingController idNumberControler;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameControler = TextEditingController(text: widget.profileModel.name ?? "");
    emailControler =
        TextEditingController(text: widget.profileModel.email ?? "");
    phoneControler =
        TextEditingController(text: widget.profileModel.phone ?? "");
    idNumberControler =
        TextEditingController(text: widget.profileModel.idNumber ?? "");
  }

  @override
  void dispose() {
    nameControler.dispose();
    emailControler.dispose();
    phoneControler.dispose();
    idNumberControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state is EditProfileError) {
          Fluttertoast.showToast(
            msg: locale.errorData!,
            backgroundColor: const Color(0xffF6A9A9),
            textColor: Colors.red,
          fontSize: 14.sp,
          );
        }
        if (state is EditProfileLoaded) {
          Fluttertoast.showToast(
            msg: locale.doneEditProfile,
            backgroundColor:backgroundColor(context),
            textColor:headingColor(context),
          fontSize: 14.sp,
          );
          BlocProvider.of<ProfileCubit>(context)
              .getProfile()
              .then((value) => Navigator.pop(context));
        }
      },
      builder: (context, state) {
        final cubit = EditProfileCubit.get(context);

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            children: [
              Stack(
                children: [
                  DottedBorder(
                    borderType: BorderType.Circle,
                    color: mainTypographyColor(context),
                    strokeWidth: 2.w,
                    child: Container(
                      width: 160.w,
                      height: 160.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: cubit.imagePathFace.isEmpty
                              ? NetworkImage(widget.profileModel.avatar!)
                              : FileImage(File(cubit.imagePathFace))
                          as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Bounce(
                      onTap: () => cubit.getImage(context),
                      child: CircleAvatar(
                        radius: 22.r,
                        backgroundColor:iconDefaultColor(context),
                        child: Icon(
                          Icons.edit,
                          size: 25.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Form(
                  key: _formKey,
                  child: ContainerTileWidget(widgets: [
                    ADPrimTextForm(
                      auth: true,
                      controller: nameControler,
                      type: TextInputType.name,
                      label: locale.enterName.toString(),
                      pIcon: Icons.person,
                      validat: (v) => Validate.validateName(context, v),
                    ),
                    SizedBox(height: 16.h),
                    ADPrimTextForm(
                      auth: true,
                      controller: emailControler,
                      type: TextInputType.emailAddress,
                      label: locale.emailAddress.toString(),
                      pIcon: Icons.email,
                      validat: (v) => Validate.validateEmail(context, v),
                    ),
                    SizedBox(height: 16.h),
                    ADPrimTextForm(
                      auth: true,
                      controller: phoneControler,
                      type: TextInputType.phone,
                      label: locale.phoneNumber,
                      pIcon: Icons.phone_iphone_outlined,
                    ),
                    SizedBox(height: 16.h),
                    Stack(
                      children: [
                        DottedBorder(
                          borderType: BorderType.RRect,
                          radius: Radius.circular(10.r),
                          color: Theme.of(context).colorScheme.primary,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  child: WidgetZoom(
                                    zoomWidget: widget.profileModel
                                        .user_license !=
                                        null &&
                                        widget.profileModel.user_license!
                                            .isNotEmpty
                                        ? Image.network(
                                      widget.profileModel.user_license!,
                                      fit: BoxFit.contain,
                                    )
                                        : Image.file(
                                      File(cubit.imagePathFaceLicence),
                                      fit: BoxFit.contain,
                                    ),
                                    heroAnimationTag:
                                    widget.profileModel.user_license ??
                                        "licence",
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 160.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                image: cubit.imagePathFaceLicence.isNotEmpty
                                    ? DecorationImage(
                                  image: FileImage(
                                      File(cubit.imagePathFaceLicence)),
                                  fit: BoxFit.cover,
                                )
                                    : widget.profileModel.user_license != null
                                    ? DecorationImage(
                                  image: NetworkImage(widget
                                      .profileModel.user_license!),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                                color: Colors.grey[200],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10.h,
                          right: 10.w,
                          child: Bounce(
                            onTap: () => cubit.getImageLicence(context),
                            child: CircleAvatar(
                              radius: 22.r,
                              backgroundColor:iconDefaultColor(context),
                              child: Icon(
                                Icons.edit,
                                size: 20.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    state is EditProfileLoading
                        ? const Center(
                      child: LoadingIndicator(),
                    )
                        : InkWell(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            final connectivityResult =
                            await Connectivity().checkConnectivity();
                            final hasConnection =
                                connectivityResult != ConnectivityResult.none;

                            if (!hasConnection) {
                              Fluttertoast.showToast(
                                msg: "لا يوجد اتصال بالإنترنت",
                                backgroundColor: const Color(0xffF6A9A9),
                                textColor: Colors.red,
                              fontSize: 14.sp,
                              );
                              return;
                            }

                            log(cubit.imagePathFace);
                            log(cubit.imagePathFaceLicence);
                            cubit.editProfile(
                              image: cubit.imagePathFace,
                              name: nameControler.text,
                              email: emailControler.text,
                              phone: phoneControler.text,
                              profileModel: widget.profileModel,
                              licenceFace: cubit.imagePathFaceLicence,
                            );
                          }
                        },
                        child: ADGradientButton(locale.save)),
                    SizedBox(height: 16.h),
                    InkWell(
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: ResetPasswordScrean(),
                        );
                      },
                      child: Container(
                        height: 50.h,
                        width: double.infinity,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 2.w,
                              color: strokeMainColor(context),
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            locale.resetPassword!,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: paragraphColor(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}