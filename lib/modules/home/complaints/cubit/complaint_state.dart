// cubit/complaint_state.dart

abstract class ComplaintState {}

class ComplaintInitial extends ComplaintState {}

class ComplaintLoading extends ComplaintState {}

class ComplaintSuccess extends ComplaintState {}

class ComplaintError extends ComplaintState {
  final String message;
  ComplaintError(this.message);
}
