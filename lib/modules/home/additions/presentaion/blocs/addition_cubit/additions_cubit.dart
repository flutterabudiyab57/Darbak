import 'dart:developer';
import 'package:darbak/modules/home/additions/data/models/automated_step_one_order_model.dart';
import 'package:darbak/modules/home/additions/data/models/step_one_order_model.dart';
import 'package:darbak/modules/home/additions/data/repositories/addition_repository.dart';
import 'package:darbak/modules/home/all_bookings/presentaion/bloc/allbooking_cubit.dart';
import 'package:darbak/modules/home/blocs/booking_cubit/booking_cubit.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../all_bookings/data/model/check_order_step_model.dart';
import '../../../../search_screen/data/models/filter_model.dart';
import '../../../data/datasource/remote/order_addition_remote_datasource.dart';
import '../../../data/repositories/addition_repository.dart';

part 'additions_state.dart';

class AdditionsCubit extends Cubit<AdditionsState> {
  final AdditionRepository additionRepository;
  final SearchCubit searchCubit;
  final AllBookingCubit allBookingCubit;
  final OrderAdditionsRemoteDatasource orderAdditionsRemoteDatasource;

  AdditionsCubit(this.additionRepository, this.searchCubit,
      this.allBookingCubit, this.orderAdditionsRemoteDatasource)
      : super(AdditionsInitial());

  static AdditionsCubit get(context) => BlocProvider.of(context);

  double total = 0.0;
  List<int> additions = [];
  List<Feature?>? features;
  List<Features?>? features2;
  StepOneOrderModel? stepOneOrderModel;
  AutomatedStepOneOrderModel? automatedStepOneOrderModel;
  FilterModel? filterModel;

  Future<void> getCarFeatures(
      BuildContext context,
      String carId,
      FilterModel? filterModel,
      ) async {
    this.filterModel = filterModel;
    emit(AdditionsLoading());

    try {
      final order = await additionRepository.getCarOrder(
        receiveBranchId: searchCubit.selectedReceiveModel?.id?.toString()
            ?? searchCubit.selectedDriveModel!.id.toString(),
        driveBranchId: searchCubit.selectedDriveModel!.id.toString(),
        receiveTimeValue: searchCubit.receiveTimeValue.toString(),
        driveTimeValue: searchCubit.driveTimeValue.toString(),
        receiveDate: searchCubit.receiveDateValue,
        driveDate: searchCubit.driveDateValue,
        carId: carId,
        pickupLat: filterModel?.pickupLat,
        pickupLong: filterModel?.pickupLong,
        dropoffLat: filterModel?.dropoffLat,
        dropoffLong: filterModel?.dropoffLong,
      );

      BlocProvider.of<BookingCubit>(context).orderID = order!.order!.id;
      BlocProvider.of<BookingCubit>(context).days = order.diff;
      total = (order.diff?.toDouble() ?? 0.0) *
          (order.order?.car?.priceAfter ?? 0.0);
      stepOneOrderModel = order;
      features = order.features;
      emit(AdditionsSuccess(order.features));
    } catch (e) {
      print("eerrerrerrer ;;;;;;;;;;: " + e.toString());
      emit(AdditionsFailed(e.toString()));
    }
  }
  CheckOrderStepModel? stepModel;
  int? additionsDataId;
  int? ids;

  Future<void> checkOrderStep({required orderId}) async {
    emit(CheckOrderStateLoading());
    try {
      stepModel = await orderAdditionsRemoteDatasource.checkBookingSteps(
          orderId: orderId);
      emit(CheckOrderStateSuccess(stepModel: stepModel!));
    } catch (e) {
      log(e.toString());
      emit(CheckOrderStateError(error: e.toString()));
    }
  }

  // add addition to the list of additions
  addAddition(BuildContext context, Feature? feature) {
    additions.add(int.parse(feature!.id.toString()));
    final daysPrice = double.parse(feature.daily!
        ? BlocProvider.of<BookingCubit>(context).days!.toString()
        : "1");
    total = total + (double.parse(feature.price.toString()) * daysPrice);
    emit(AdditionsLoading());
    emit(AdditionsSuccess(features));
  }

// to clear additions
  void clearAdditions() {
    additions.clear();
    total = 0.0;
    emit(AdditionsSuccess(features));
  }

  // remove addition from the list of additions
  void removeAddition(BuildContext context, Feature? feature) {
    if (feature == null) return;
    additions.remove(int.tryParse(feature.id?.toString() ?? ''));
    final daysStr = feature.daily == true
        ? BlocProvider.of<BookingCubit>(context).days?.toString()
        : "1";
    final daysPrice = double.tryParse(daysStr ?? '1') ?? 1;

    final price = double.tryParse(feature.price?.toString() ?? '') ?? 0;

    total -= price * daysPrice;

    emit(AdditionsLoading());
    emit(AdditionsSuccess(features));
  }


  addAdditionNotCompleted(BuildContext context, Features? feature) {
    additions.add(int.parse(feature!.id.toString()));
    final daysPrice = double.parse(feature.daily!
        ? BlocProvider.of<BookingCubit>(context).days!.toString()
        : "1");
    total = total + (double.parse(feature.price.toString()) * daysPrice);
    emit(AdditionsNotCompletedLoading());
    emit(AdditionsNotCompletedSuccess(features2));
    print(additions.toString() + "123");
  }

  removeAdditionNotCompleted(BuildContext context, Features? feature) {
    additions.remove(int.parse(feature!.id.toString()));
    final daysPrice = double.parse(feature.daily!
        ? BlocProvider.of<BookingCubit>(context).days!.toString()
        : "1");
    total = total - (double.parse(feature.price.toString()) * daysPrice);
    emit(AdditionsNotCompletedLoading());
    emit(AdditionsNotCompletedSuccess(features2));
  }

  ///-------------
  List checked = [];

  initialCheckedList() {
    checked.clear();
    stepModel!.order!.features!.forEach((element) {
      checked.add(false);
    });
  }

  ///------------
  checkAdditionSelected() {
    emit(CheckAdditionSelectedLoading());
    if (stepModel!.order!.additions != 0) {
      stepModel!.order!.features!.forEach((element) {
        checkId(element.id);
      });
    } else {
      initialCheckedList();
    }
  }

  int index1 = 0;

  checkId(int id) {
    stepModel!.order!.additionsData!.asMap().forEach((index, value) {
      checked[index] = id == value.id ? true : false;
    });
  }
}
