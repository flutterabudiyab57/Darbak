import 'dart:developer';

import 'package:darbak/core/style/style.dart';
import 'package:darbak/modules/home/profile/data/models/profile_model.dart';
import 'package:darbak/modules/home/profile/page/edit_profile/datasources/remote/edit_remote_dataSource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../../core/constants/assets/app_colors.dart';
import '../../../../../../../language/locale.dart';
import '../../../../../../widgets/Dashed_divider.dart';
import '../../../../../../widgets/components/ad_gradient_btn.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this.editProfileDataSource) : super(EditProfileInitial());
  static EditProfileCubit get(context) => BlocProvider.of(context);

  final EditProfileDataSource editProfileDataSource;
  final ImagePicker _picker = ImagePicker();

  String imagePathFace = "";
  String imagePathFaceLicence = "";

  Future<void> _showImageSourceSheet(
      BuildContext context, {
        required Future<void> Function(ImageSource) onPick,
      }) async {
    final locale = AppLocalizations.of(context)!;
    final isRTL = locale.isDirectionRTL(context);

    final source = await showModalBottomSheet<ImageSource>(
      useRootNavigator: true,
      context: context,
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      backgroundColor: backgroundColor(context),
      shape:   RoundedRectangleBorder(

        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => Builder(
        builder: (innerContext) => SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: strokeGrayColor(context),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: Text(
                  isRTL ? 'اختر مصدر الصورة' : 'Choose image source',
                  style: AppTypography.headingColor18(context),
                ),
              ),
              Divider(height: 1.h, color: strokeGrayColor(context)),
              ListTile(
                leading:Icon(
                    Icons.photo_library_rounded,
                    color: iconDefaultColor(context),
                      size:18.sp
                ),
                title: Text(
                  isRTL ? 'معرض الصور' : 'Photo Library',
                  style: AppTypography.paragraphColor15(context),
                ),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
              dashedDivider(context),
              ListTile(
                leading:  Icon(
                    Icons.camera_alt_rounded,
                    color: iconDefaultColor(context),
                      size:18.sp
                  ),

                title: Text(
                  isRTL ? 'الكاميرا' : 'Camera',
                  style: AppTypography.paragraphColor15(context),
                ),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              dashedDivider(context),

              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: GestureDetector(
                  onTap: () => Navigator.pop(sheetContext),
                  child: ADGradientButton(
                    isRTL ? 'إلغاء' : 'Cancel',
                    height: 50.h,
                  ),
                ),
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      await onPick(source);
    }
  }

  Future<void> getImage(BuildContext context) async {
    await _showImageSourceSheet(context, onPick: (source) async {
      emit(ImageProfileLodingState());
      try {
        final XFile? picked = await _picker.pickImage(source: source);
        if (picked != null) {
          imagePathFace = picked.path;
          emit(ImageProfileScussesState());
        }
      } catch (e) {
        emit(ImageProfileErrorState(error: e.toString()));
      }
    });
  }

  Future<void> getImageLicence(BuildContext context) async {
    await _showImageSourceSheet(context, onPick: (source) async {
      emit(ImageLicenceLoadingState());
      try {
        final XFile? picked = await _picker.pickImage(source: source);
        if (picked != null) {
          imagePathFaceLicence = picked.path;
          emit(ImageLicenceLSuccessState());
        }
      } catch (e) {
        emit(ImageLicenceLErrorState(error: e.toString()));
      }
    });
  }
  /// The always-sent field set, taken from the cached profile.
  ///
  /// `POST /profile` appears to treat name/email/phone as required — the
  /// original all-at-once [editProfile] backfilled them from the cached model
  /// for exactly that reason — so every partial write ships them too and only
  /// overrides the key the user actually touched.
  Map<String, String> _baseFields(ProfileModel profileModel) => {
        "name": profileModel.name ?? "",
        "email": profileModel.email ?? "",
        "phone": profileModel.phone ?? "",
      };

  /// Updates a single profile field.
  ///
  /// [EditProfileDataSource] passes its `data` map straight through to
  /// `item.fields`, so no datasource change is needed for a partial write.
  Future<void> updateField({
    required String key,
    required String value,
    required ProfileModel profileModel,
  }) async {
    emit(EditProfileLoading());
    try {
      final data = _baseFields(profileModel);
      data[key] = value;

      await editProfileDataSource.editProfile(
        image: "",
        licenceImage: "",
        data: data,
      );
      emit(EditProfileLoaded());
    } catch (e) {
      log(e.toString());
      emit(EditProfileError(e.toString()));
    }
  }

  /// Uploads a new avatar, leaving the text fields at their current values.
  Future<void> uploadAvatar(
    String path, {
    required ProfileModel profileModel,
  }) async {
    emit(EditProfileLoading());
    try {
      await editProfileDataSource.editProfile(
        image: path,
        licenceImage: "",
        data: _baseFields(profileModel),
      );
      emit(EditProfileLoaded());
    } catch (e) {
      log(e.toString());
      emit(EditProfileError(e.toString()));
    }
  }

  /// Uploads a new driving-licence image, leaving the text fields untouched.
  Future<void> uploadLicence(
    String path, {
    required ProfileModel profileModel,
  }) async {
    emit(EditProfileLoading());
    try {
      await editProfileDataSource.editProfile(
        image: "",
        licenceImage: path,
        data: _baseFields(profileModel),
      );
      emit(EditProfileLoaded());
    } catch (e) {
      log(e.toString());
      emit(EditProfileError(e.toString()));
    }
  }

  Future<void> editProfile({
    required String image,
    required String name,
    required String email,
    required String phone,
    required ProfileModel profileModel,
    required String licenceFace,
  }) async {
    emit(EditProfileLoading());
    try {
      await editProfileDataSource.editProfile(
        image: image.isEmpty ? "" : image,
        licenceImage: licenceFace.isEmpty ? "" : licenceFace,
        data: {
          "name": name.isEmpty ? profileModel.name! : name,
          "email": email.isEmpty ? profileModel.email! : email,
          "phone": phone.isEmpty ? profileModel.phone! : phone,
        },
      );
      emit(EditProfileLoaded());
    } catch (e) {
      log(e.toString());
      emit(EditProfileError(e.toString()));
    }
  }
}