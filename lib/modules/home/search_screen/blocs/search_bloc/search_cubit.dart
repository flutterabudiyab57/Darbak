import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/enums.dart';
import 'package:darbak/modules/home/all_branching/data/models/branch_model.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_state.dart';
import 'package:darbak/modules/home/search_screen/data/datasources/remote/areas_remote_datasource.dart';
import 'package:darbak/modules/home/search_screen/data/datasources/remote/check_date_remote.dart';
import 'package:darbak/modules/home/search_screen/data/datasources/remote/regions_remote_datasource.dart';
import 'package:darbak/modules/home/search_screen/data/models/areas_model.dart';
import 'package:darbak/modules/home/search_screen/data/models/offers_model.dart';
import 'package:darbak/modules/home/search_screen/data/models/regions_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/datasources/remote/offers_remte_datasource.dart';

class SearchCubit extends Cubit<SearchState> {
  final DateCheckerRemote dateCheckerRemote;
  final RegionsRemoteDatasource regionsRemoteDatasource;
  final AreasRemoteDatasource areasRemoteDatasource;
  double? pickupLat;
  double? pickupLong;
  double? dropoffLat;
  double? dropoffLong;
  SearchCubit(this.dateCheckerRemote, this.regionsRemoteDatasource,
      this.areasRemoteDatasource)
      : super(SearchInitial());

  static SearchCubit get(context) => BlocProvider.of(context);
  RentType rentType = RentType.classic;

  bool isAutomated() => rentType == RentType.automated;

  String? selectedReceiveArea;
  String? selectedDriveArea;

  late DateTime receiveDateValue = DateTime.now();
  late DateTime driveDateValue = DateTime.now();

  late TimeOfDay receiveTimeValue = TimeOfDay.now();
  late TimeOfDay driveTimeValue = TimeOfDay.now();

  // These two fields are a remnant, not a design. Every writer is a
  // converted screen that already holds the same branch in
  // LocationSelectionCubit, and every reader is either validate() (two
  // lines later) or that same screen's own listener. The round trip
  // through this app-wide singleton is redundant — it survives only
  // because validate()'s signature takes its ids from here. Removing it
  // means changing validate()'s signature or reading the ids from
  // LocationSelectionCubit at the call site. That is SearchCubit's search
  // logic, explicitly out of scope for the location rewrite, so it was
  // left deliberately. It is the last place branch identity passes
  // through global state.
  BranchModel? selectedReceiveModel;
  BranchModel? selectedDriveModel;

  AreasModel? selectedAreaReceiveModel;
  AreasModel? selectedAreaDriveModel;

  List<RegionModel>? regionsData = [];
  List<AreasModel>? areasData = [];
  int differenceInDays = 0;

  getRegions() async {
    emit(SearchLoading());
    try {
      final regions = await regionsRemoteDatasource.getRegions();
      regionsData = regions;
      emit(RegionsSuccess(regions));
    } catch (error) {
      emit(SearchFailed(error.toString()));
    }
  }

  void clearAllDataSearched() {
    receiveDateValue = DateTime.now();
    driveDateValue = DateTime.now();

    receiveTimeValue = TimeOfDay.now();
    driveTimeValue = TimeOfDay.now();
     pickupLat = null;
    pickupLong = null;
    dropoffLat = null;
    dropoffLong = null;
  }

  void updateDates(DateTime receiveDate, DateTime driveDate) {
    receiveDateValue = receiveDate;
    driveDateValue = driveDate;

    // Calculate difference in days
    differenceInDays = driveDate.difference(receiveDate).inDays;
    final differenceInHours = driveDate.difference(receiveDate).inHours;

    if (differenceInHours > (differenceInDays * 24) + 7) {
      differenceInDays += 1;
    }
  }

  getAreas({int pageNumber = 1, int? regionId}) async {
    emit(SearchLoading());
    try {
      final areas = await areasRemoteDatasource.getAreas(
        pageIndex: pageNumber,
        regionId: regionId,
      );
      regionId != null ? areasData = areas : areasData?.addAll(areas);
      areasData = areas;
      pageNumber++;
      emit(GetAreaSuccess(areas));
      if (pageNumber <= 3 && regionId == null) {
        getAreas(pageNumber: pageNumber);
      }
    } catch (error) {
      emit(SearchFailed(error.toString()));
    }
  }

  Future<void> validate() async {
    emit(SearchCheckLoading());
    try {
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      String formatDateTime(DateTime date) {
        return dateFormat.format(date);
      }


      if (selectedReceiveModel == null) {
        emit(SearchInvalid(
            "Please select both a receiving and delivery branch and date."));
        print("Validation failed: Missing receive/delivery data.");
        return;
      }

      String receivingId = selectedReceiveModel!.id.toString();
      String deliveryId = selectedDriveModel?.id.toString() ?? receivingId;
      String receivingDate = formatDateTime(receiveDateValue);
      String deliveryDate = formatDateTime(driveDateValue);

      print("Validating with receivingId: $receivingId, deliveryId: $deliveryId, "
          "receivingDate: $receivingDate, deliveryDate: $deliveryDate");

      final response = await dateCheckerRemote.validate(
        receivingId: receivingId,
        deliveryId: deliveryId,
        receivingDate: receivingDate,
        deliveryDate: deliveryDate,
      );

      if (response == "success") {
        emit(SearchValidate(response));
        print("SearchValidate: $response");
      } else {
        emit(SearchInvalid(response));
        print("SearchInvalid: $response");
      }
    } catch (error) {
      if (error is DioException) {
        print("Dio error: ${error.response?.data ?? error.message}");
        print("Dio error status: ${error.response?.statusCode}");
        print("Dio error headers: ${error.response?.headers}");
      } else {
        print("Search error: $error");
      }
      emit(SearchFailed(error.toString()));
    }
  }

  Future<void> validateDelivery() async {
    emit(SearchCheckLoading());
    try {
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      String formatDateTime(DateTime date) {
        return dateFormat.format(date);
      }

      String receivingId = selectedReceiveModel!.id.toString();
      String deliveryId = selectedDriveModel?.id.toString() ?? receivingId;
      String receivingDate = formatDateTime(receiveDateValue);
      String deliveryDate = formatDateTime(driveDateValue);

      print("Validating with receivingId: $receivingId, deliveryId: $deliveryId, "
          "receivingDate: $receivingDate, deliveryDate: $deliveryDate");

      // Making the API call for validation
      final response = await dateCheckerRemote.validate(
        receivingId: receivingId,
        deliveryId: deliveryId,
        receivingDate: receivingDate,
        deliveryDate: deliveryDate,
      );

      if (response == "success") {
        emit(SearchValidate(response));
        print("Validation succeeded: $response");
      } else {
        emit(SearchInvalid(response));
        print("Validation failed: $response");
      }
    } catch (error) {
      // Handling and logging errors
      if (error is DioException) {
        print("Dio error: ${error.response?.data ?? error.message}");
      } else {
        print("Validation error: $error");
      }
      emit(SearchFailed(error.toString()));
    }
  }

  changeState() {
    emit(SearchLoading());
    emit(RegionsSuccess(regionsData));
  }

  ///Offers Methods
  OffersRemotDataSource? offersRemotDataSource;
  OffersModel? offersModel;
  String? message;
  int? discountValue;

  Future<void> getOffers() async {
    emit(OffersLoding());
    try {
      final List<OffersModel> offersList = await OffersRemotDataSource.getOffers(langCode);

      if (offersList.isNotEmpty) {
        message = offersList[0].name;
        discountValue = offersList[0].discountValue;
      }

      emit(OffersLoded(offersList)); // OffersLoded يستقبل List<OffersModel>
    } catch (e) {
      emit(OffersErorr(e.toString()));
    }
  }
}
