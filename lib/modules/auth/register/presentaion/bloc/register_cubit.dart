import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/datasources/remote/register_remote_datasource.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this.registerRemoteDatasource) : super(RegisterInitial());

  static RegisterCubit get(context) => BlocProvider.of(context);
  final RegisterRemoteDatasource registerRemoteDatasource;

  var picker = ImagePicker();
  XFile? imageProfile;
  String imagePathFace = "";

  getImage(String type) async {
    emit(ImageProfileLodingState());
    try {
      if (type == "camera") {
        imageProfile = await picker.pickImage(source: ImageSource.camera);
      } else if (type == "gallery") {
        imageProfile = await picker.pickImage(source: ImageSource.gallery);
      }

      if (imageProfile != null) {
        imagePathFace = imageProfile!.path;
        emit(ImageProfileScussesState());
      } else {
        emit(ImageProfileErrorState(error: "Image selection cancelled"));
      }
    } catch (e) {
      emit(ImageProfileErrorState(error: e.toString()));
    }
  }

  Future<void> userRegister({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passworConfirm,
    required String idNumber,
    required String licenceFace,
    required String country_key,

  }) async {
    emit(RegisterLoading());
    print("before register");
    try {
      final response = await registerRemoteDatasource.signup({
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
        "password_confirmation": passworConfirm,
        "id_number": idNumber,
        "phone_country_code": "+$country_key",
      }, licenceFace);

      print("📦 Response from API: $response");
      print("📦 Response  password: $password");



      if (response['requires_verification'] == true) {
        emit(RegisterRequiresVerification(
          userId: response['user_id'].toString(),
          phone: phone,
        ));
      } else {
        emit(RegisterSuccess());
      }
    } catch (e) {
      emit(RegisterError(e.toString()));

      print("📦 Response from API: ${e}");


    }
  }
}