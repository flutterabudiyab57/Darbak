import 'dart:io';

import 'package:bounce/bounce.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:widget_zoom/widget_zoom.dart';

import '../../../../../../../core/constants/assets/app_colors.dart';
import '../../../../../../../core/helpers/helper/Network_error_widget.dart';
import '../../../../../../../core/helpers/validation/validation.dart';
import '../../../../../../../core/router/routes.dart';
import '../../../../../../../core/style/style.dart';
import '../../../../../../../language/locale.dart';
import '../../../../../../../service_locator.dart';
import '../../../../../../widgets/components/gradient_hero_panel.dart';
import '../../../../../../widgets/components/hero_app_bar_row.dart';
import '../../../../../../widgets/components/info_row_card.dart';
import '../../../../../search_screen/presentaion/widget/shimmer_list.dart';
import '../../../../blocs/profile_cubit/profile_cubit.dart';
import '../bloc/edit_profile_cubit.dart';
import '../bloc/edit_profile_state.dart';
import '../widget/edit_field_dialog.dart';
import '../widget/image_source_sheet.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor(context),
        // No appBar: the hero panel is the first item of the scroll view, so it
        // travels up with the content and paints behind the status bar.
        body: BlocProvider(
          create: (context) => sl<EditProfileCubit>(),
          child: const _EditProfileContent(),
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
        msg: AppLocalizations.of(context)!.noInternetConnection,
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
        if (profileState is ProfileLoading) {
          return Center(child: ShimmerLoadingList(itemCount: 4));
        }

        if (profileState is ProfileSuccess) {
          return _EditProfileBody(profileModel: profileState.profileModel);
        }

        if (profileState is ProfileFailed) {
          return NetworkErrorWidget(onRetry: _loadProfileData);
        }

        return Center(
          child: ElevatedButton(
            onPressed: _loadProfileData,
            child: Text(AppLocalizations.of(context)!.loadingData),
          ),
        );
      },
    );
  }
}

class _EditProfileBody extends StatelessWidget {
  final dynamic profileModel;

  const _EditProfileBody({required this.profileModel});

  /// The Figma panel is 337 tall including the 50px status-bar mock;
  /// [GradientHeroPanel] adds the device's real inset on top of this.
  static const double _panelHeight = 337;

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
            backgroundColor: backgroundColor(context),
            textColor: headingColor(context),
            fontSize: 14.sp,
          );
          // Stays put: each edit saves on its own now, so there is no single
          // "done" moment to navigate away from.
          BlocProvider.of<ProfileCubit>(context).getProfile();
        }
      },
      builder: (context, state) {
        final cubit = EditProfileCubit.get(context);

        return Stack(
          children: [
            ListView(
              // Stops ListView injecting MediaQuery padding above the panel;
              // the panel's own SafeArea owns that inset.
              padding: EdgeInsets.zero,
              children: [
                _panel(context, locale, cubit),
                Padding(
                  padding: EdgeInsets.fromLTRB(15.w, 20.h, 15.w, 24.h),
                  child: Column(
                    children: [
                      _emailRow(context, locale, cubit),
                      SizedBox(height: 15.h),
                      _phoneRow(context, locale, cubit),
                      SizedBox(height: 15.h),
                      InfoRowCard(
                        icon: Icons.lock_outline,
                        label: locale.password.toString(),
                        value: '********',
                        // Not edited in place: the reset flow has its own
                        // screen with the current-password check.
                        onEdit: () => context.pushNamed(Routes.resetPassword),
                      ),
                      SizedBox(height: 15.h),
                      InfoRowCard(
                        icon: Icons.badge_outlined,
                        label: locale.idNumber.toString(),
                        value: _maskedId(profileModel.idNumber),
                        // Read-only: the ID is fixed once the account is
                        // verified, and the design shows it masked.
                        onEdit: null,
                      ),
                      SizedBox(height: 15.h),
                      _LicenceCard(profileModel: profileModel, cubit: cubit),
                    ],
                  ),
                ),
              ],
            ),
            if (state is EditProfileLoading) ...[
              const ModalBarrier(dismissible: false, color: Colors.black26),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        );
      },
    );
  }

  Widget _panel(
      BuildContext context, AppLocalizations locale, EditProfileCubit cubit) {
    return GradientHeroPanel(
      height: _panelHeight.h,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 27.h),
      child: Column(
        spacing: 12.h,
        mainAxisSize: MainAxisSize.min,
        children: [
          HeroAppBarRow(title: locale.personalProfile),
          // SizedBox(height: 16.h),
          _avatar(context, cubit),
          // SizedBox(height: 18.h),
          _nameRow(context, locale, cubit),
        ],
      ),
    );
  }

  Widget _avatar(BuildContext context, EditProfileCubit cubit) {
    final ImageProvider? image = cubit.imagePathFace.isNotEmpty
        ? FileImage(File(cubit.imagePathFace))
        : (profileModel.avatar != null && profileModel.avatar!.isNotEmpty
            ? NetworkImage(profileModel.avatar!) as ImageProvider
            : null);

    return SizedBox(
      width: 125.w,
      height: 125.w,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: onHeroPrimary.withValues(alpha: 0.15),
                image: image == null
                    ? null
                    : DecorationImage(image: image, fit: BoxFit.cover),
              ),
            ),
          ),
          // Absolute `right`, not PositionedDirectional: the design keeps the
          // camera on the visual right in both directions.
          Positioned(
            right: 4.w,
            bottom: 0,
            child: Bounce(
              onTap: () async {
                final source = await showImageSourceSheet(context);
                if (source == null) return;
                await cubit.pickAvatar(source);
                if (cubit.imagePathFace.isNotEmpty) {
                  await cubit.uploadAvatar(
                    cubit.imagePathFace,
                    profileModel: profileModel,
                  );
                }
              },
              child: Container(
                width: 45.w,
                height: 45.w,
                decoration: const BoxDecoration(
                  color: heroNavy,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  size: 25.sp,
                  color: onHeroPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameRow(
      BuildContext context, AppLocalizations locale, EditProfileCubit cubit) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final value = await showEditFieldDialog(
          context,
          icon: Icons.person_outline,
          title: locale.enterName.toString(),
          initialValue: profileModel.name ?? '',
          keyboardType: TextInputType.name,
          validator: (v) => Validate.validateName(context, v),
        );
        if (value != null && value.isNotEmpty) {
          await cubit.updateField(
            key: 'name',
            value: value,
            profileModel: profileModel,
          );
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              profileModel.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.heroAppBarTitle20(context)
                  .copyWith(fontSize: 18.sp),
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.edit_outlined, size: 18.sp, color: onHeroPrimary),
        ],
      ),
    );
  }

  Widget _emailRow(
      BuildContext context, AppLocalizations locale, EditProfileCubit cubit) {
    return InfoRowCard(
      icon: Icons.mail_outline,
      label: locale.emailAddress.toString(),
      value: profileModel.email ?? '',
      onEdit: () async {
        final value = await showEditFieldDialog(
          context,
          icon: Icons.mail_outline,
          title: locale.emailAddress.toString(),
          initialValue: profileModel.email ?? '',
          keyboardType: TextInputType.emailAddress,
          validator: (v) => Validate.validateEmail(context, v),
        );
        if (value != null && value.isNotEmpty) {
          await cubit.updateField(
            key: 'email',
            value: value,
            profileModel: profileModel,
          );
        }
      },
    );
  }

  Widget _phoneRow(
      BuildContext context, AppLocalizations locale, EditProfileCubit cubit) {
    return InfoRowCard(
      icon: Icons.phone_outlined,
      label: locale.phoneNumber,
      value: profileModel.phone ?? '',
      onEdit: () async {
        final value = await showEditFieldDialog(
          context,
          icon: Icons.phone_outlined,
          title: locale.phoneNumber,
          initialValue: profileModel.phone ?? '',
          keyboardType: TextInputType.phone,
        );
        if (value != null && value.isNotEmpty) {
          await cubit.updateField(
            key: 'phone',
            value: value,
            profileModel: profileModel,
          );
        }
      },
    );
  }

  /// Shows only the leading digit, as the design does: `3XXXXXXXXXXXXX`.
  static String _maskedId(String? id) {
    if (id == null || id.isEmpty) return '';
    return id[0] + ('X' * (id.length - 1));
  }
}

class _LicenceCard extends StatelessWidget {
  final dynamic profileModel;
  final EditProfileCubit cubit;

  const _LicenceCard({required this.profileModel, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    final localPath = cubit.imagePathFaceLicence;
    final remoteUrl = profileModel.user_license as String?;
    final hasLicence =
        localPath.isNotEmpty || (remoteUrl != null && remoteUrl.isNotEmpty);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: backgroundColor(context),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: bg2Color(context), width: 1.5.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locale.drivingLicense,
              style: AppTypography.headingColor16(context)),
          // The "not uploaded" pill would be a lie once an image exists.
          if (!hasLicence) ...[
            SizedBox(height: 4.h),
            _statusBadge(context, locale),
          ],
          SizedBox(height: 15.h),
          hasLicence
              ? _preview(context, localPath, remoteUrl)
              : _dropZone(context, locale),
        ],
      ),
    );
  }

  Widget _statusBadge(BuildContext context, AppLocalizations locale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg2Color(context),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: locale.notUploadedYet,
              style: AppTypography.headingColor10(context),
            ),
            TextSpan(
              text: locale.requiredToCompleteBooking,
              style: AppTypography.headingColor10(context)
                  .copyWith(color: paragraphNavyColor(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preview(BuildContext context, String localPath, String? remoteUrl) {
    final ImageProvider image = localPath.isNotEmpty
        ? FileImage(File(localPath))
        : NetworkImage(remoteUrl!) as ImageProvider;

    return Stack(
      children: [
        GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => Dialog(
              child: WidgetZoom(
                heroAnimationTag: remoteUrl ?? 'licence',
                zoomWidget: Image(image: image, fit: BoxFit.contain),
              ),
            ),
          ),
          child: Container(
            height: 132.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              image: DecorationImage(image: image, fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          right: 10.w,
          bottom: 10.h,
          child: Bounce(
            onTap: () => _pickAndUpload(context),
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor: iconDefaultColor(context),
              child: Icon(Icons.edit, size: 18.sp, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropZone(BuildContext context, AppLocalizations locale) {
    return GestureDetector(
      onTap: () => _pickAndUpload(context),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: Radius.circular(12.r),
        color: strokeGrayColor(context),
        child: SizedBox(
          height: 132.h,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: bg2Color(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_upload_outlined,
                    size: 20.sp, color: paragraphNavyColor(context)),
              ),
              SizedBox(height: 12.h),
              Text(
                locale.tapToUploadImage,
                textAlign: TextAlign.center,
                style: AppTypography.paragraphColor16(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final source = await showImageSourceSheet(context);
    if (source == null) return;
    await cubit.pickLicence(source);
    if (cubit.imagePathFaceLicence.isNotEmpty) {
      await cubit.uploadLicence(
        cubit.imagePathFaceLicence,
        profileModel: profileModel,
      );
    }
  }
}
