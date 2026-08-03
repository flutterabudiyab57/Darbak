import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/router/routes.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
import '../../../../widgets/components/appbar.dart';
import '../../data/models/cars_model.dart';
import '../widget/car_search_item.dart';
import 'car_service.dart';

class SearchCarScreen extends StatefulWidget {
  const SearchCarScreen({super.key});

  @override
  State<SearchCarScreen> createState() => _SearchCarScreenState();
}

class _SearchCarScreenState extends State<SearchCarScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CarService _carService = CarService();
  List<DataCars> _carsList = [];
  Timer? _debounceTimer;

  void _onSearchChanged(String searchTerm) {
    _debounceTimer?.cancel();

    if (searchTerm.isEmpty) {
      setState(() => _carsList.clear());
      return;
    }

    if (searchTerm.length < 2) return;
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchCars(searchTerm);
    });
  }

  Future<void> _searchCars(String searchTerm) async {
    try {
      final cars = await _carService.searchCars(searchTerm);
      setState(() => _carsList = cars);
    } catch (e) {
      if (e.toString().contains('cancelled')) return;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor(context),
        appBar: CustomAppBar(
          title:locale.searchCar.toString(),
          showBackButton: true,
          // showThemeToggle: true,
        ),
        body: Padding(
          padding:  EdgeInsets.all(15.sp),
          child: Column(
            spacing: 10.h,
            children: [
              _buildSearchField(locale),

              Expanded(
                child: _carsList.isEmpty
                    ? _buildEmptySearchWidget(locale)
                    : _buildCarList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(locale) {
    final bool isRTL = locale.isDirectionRTL(context);

    return Container(
      child: TextField(
        controller: _searchController,
        style: AppTypography.mainTypographyColor16(context),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12.h,horizontal: 12.w),
          labelText: isRTL
              ? "ابحث عن سيارتك المفضلة"
              : "Search for your favorite car",
          labelStyle: AppTypography.paragraphColor16(context),
            hintStyle:AppTypography.mainTypographyColor16(context),
          helperStyle:AppTypography.mainTypographyColor20(context) ,
          prefixIcon: isRTL
              ? null
              : Icon(Icons.search,
            size: 25.sp,
            color: iconDefaultColor(context),
          ),

          suffixIcon: isRTL
              ? Icon(Icons.search,
            size: 25.sp,
            color: iconDefaultColor(context),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(
              color: strokeGrayColor(context),
              width: 2.w,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(
              color: strokeGrayColor(context),
              width: 2.w,
            ),
          ),
        ),
        onChanged: (searchTerm) {
          _onSearchChanged(searchTerm);
        },
      ),
    );
  }

  Widget _buildCarList() {
    return ListView.builder(
      itemCount: _carsList.length,
      itemBuilder: (context, index) {
        return CarSearchItem(
          car: _carsList[index],
          onTap: () {
            context.pushNamed(
              Routes.carsInformation,
              extra: CarsInformationArgs(datum: _carsList[index]),
            );
          },
        );      },
    );
  }

  Widget _buildEmptySearchWidget(locale) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/images/new_cars.png",
            width: 250.w, height: 200.h, fit: BoxFit.cover),
        Text(
          locale.noResultsFound,
          style:AppTypography.mainTypographyColor18(context)
        ),
      ],
    );
  }
}
