import 'package:darbak/modules/home/cars/data/datasources/remote/cars_remote_datasource.dart';
import 'package:darbak/modules/home/cars/data/models/cars_model.dart';
import 'package:darbak/modules/home/cars/presentaion/bloc/filter_cubit/filter_cubit.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import '../../../../../../core/constants/api_path.dart';
import '../../../../../../core/constants/langCode.dart';
import '../../../../../../service_locator.dart';

part 'all_cars_state.dart';

class AllCarsCubit extends Cubit<AllCarsState> {
  AllCarsCubit(this.carsRemoteDataSource) : super(AllCarsInitial());
  final filterCubit = sl<FilterCubit>();

  static AllCarsCubit get(context) => BlocProvider.of(context);

  CarsRemoteDataSource carsRemoteDataSource;
  Cars? cars;

  List<DataCars> data = [];
  List<DataCars> filteredData = [];



  Future <void> searchCars(String searchTerm) async {
    if (searchTerm.isEmpty) {
      filteredData = data;
    } else {
      try {
        final url = '$searchAboutCars/?trem=$searchTerm';

        final response = await Dio().get(
          url,
          options: Options(
            responseType: ResponseType.json,
            headers: {
              "Accept": "application/json",
              "Accept-Language": langCode.isEmpty ? "en" : langCode,
            },
          ),
        );

        print('Request URL: $url');
        print('Raw response: ${response.data.toString()}');


        if (response.statusCode == 200) {
          if (response.data != null && response.data is Map<String, dynamic>) {
            final Map<String, dynamic> jsonResponse = response.data;

            if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
              final List<DataCars> carsList = (jsonResponse['data'] as List)
                  .map((carJson) => DataCars.fromMap(carJson as Map<String, dynamic>))
                  .toList();

              filteredData = carsList;
            } else {
              filteredData = [];
              print('Received response: ${jsonResponse}');
            }
          } else {
            filteredData = [];
            print('Unexpected response: ${response.data}');
          }
        } else {
          filteredData = [];
          print('Error: Received status code ${response.statusCode} - ${response.statusMessage}');
        }
      } catch (e) {
        filteredData = [];
        if (e is DioError) {
          print('Dio error: ${e.response?.data}');
          print('Error details: ${e.message}');
        } else {
          print('Unexpected error: $e');
        }
      }
    }

    emit(CarsSearchResult(data: filteredData)); // Emit the filtered data
  }
  Future<void> getAllCars(
      int pageNumber, {
        int? branchId,
      }) async {
    emit(AllCarsLoding());
    try {
      cars = await carsRemoteDataSource.getAllCars(
        1,
        branchId: branchId,
      );

      final lastPage = cars?.meta?.lastPage ?? 1;
      // print("âœ… lastPage = $lastPage | total = ${cars?.meta?.total}");

      for (int page = 2; page <= lastPage && page <= 4; page++) {
        // print("â³ fetching page $page...");
        final moreData = await carsRemoteDataSource.getAllCars(
          page,
          branchId: branchId,
        );
        // print("âœ… page $page got ${moreData.data?.length} cars");
        cars?.data?.addAll(moreData.data ?? []);
      }

      emit(AllCarsLoded());
    } catch (e) {
      // print("an getAllCars error: $e");
      emit(AllCarsLodError(e.toString()));
    }
  }

  Future<void> getCarsByFilter(
      int pageNumber, {
        int? branchId,
      }) async {
    emit(AllCarsLoding());
    try {
      final data = await carsRemoteDataSource.getCarsByFilter(
        pageNumber: pageNumber,
        manufactoryIds: filterCubit.brands,
        categoryIds: filterCubit.categories,
        model: filterCubit.modelYear,
        minPrice: filterCubit.minPrice,
        maxPrice: filterCubit.maxPrice,
      );

      if (pageNumber == 1) {
        cars?.data = data.data;
      } else {
        cars?.data?.addAll(data.data!);
      }

      emit(AllCarsLoded());
    } catch (e) {
      emit(AllCarsLodError(e.toString()));
    }
  }

  emitPhotoError(e) {
    emit(CarsImageLoadError(e.toString()));
  }
}
