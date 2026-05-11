// cubit/complaint_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/complaint_repository.dart';
import 'complaint_state.dart';

class ComplaintCubit extends Cubit<ComplaintState> {
  final ComplaintRepository repository;

  ComplaintCubit(this.repository) : super(ComplaintInitial());

  Future<void> submitComplaint({
    required String name,
    required String phone,
    required String idNumber,
    required String description,
  }) async {
    emit(ComplaintLoading());

    try {
      await repository.sendComplaint(
        name: name,
        phone: phone,
        idNumber: idNumber,
        description: description,
      );
      emit(ComplaintSuccess());
    } catch (e) {
      emit(ComplaintError(e.toString()));
    }
  }
}
