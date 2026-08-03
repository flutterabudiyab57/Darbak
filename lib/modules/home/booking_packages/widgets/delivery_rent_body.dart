import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/assets/app_colors.dart';
import '../../../../core/helpers/Maps/map_select_location.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../core/style/style.dart';
import '../../../../language/locale.dart';
import '../../../widgets/Dashed_divider.dart';
import '../../../widgets/components/ad_gradient_btn.dart';
import '../../../widgets/time_select.dart';
import '../../all_branching/data/models/branch_model.dart';
import '../../search_screen/blocs/search_bloc/search_cubit.dart';
import '../../search_screen/blocs/search_bloc/search_state.dart';
import '../../search_screen/data/models/regions_model.dart';
import '../../search_screen/presentaion/widget/rental_summary_card.dart';
import '../Delivery_widgets/delivery_branch_selection_sheet.dart';
import '../Delivery_widgets/region_selection_bottom_sheet.dart';

class DeliveryRentBody extends StatefulWidget {
  const DeliveryRentBody({super.key});

  @override
  State<DeliveryRentBody> createState() => _DeliveryRentBodyState();
}

class _DeliveryRentBodyState extends State<DeliveryRentBody> {
  bool isLoading = false;

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropoffController = TextEditingController();

  double? pickup_lat;
  double? pickup_long;
  double? dropoff_lat;
  double? dropoff_long;

  BranchModel? _selectedBranch;
  RegionModel? _selectedRegion;
  String? _selectedRegionCity;

  String? _savedPickupAddress;
  String? _savedDropoffAddress;
  String? _savedBranchName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchCubit = context.read<SearchCubit>();
      if (searchCubit.deliveryBranchesData.isEmpty) {
        searchCubit.getDeliveryBranches();
      }
    });
  }

  @override
  void dispose() {
    pickupController.dispose();
    dropoffController.dispose();
    super.dispose();
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.locationPermissionDenied),
        ));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.permissionPermanentlyDeniedBody),
      ));
      return false;
    }
    return true;
  }

  LocationBounds? _buildBoundsFromBranch() {
    final polygon = _selectedBranch?.polygon;
    if (polygon == null || polygon.isEmpty) return null;
    final validPoints =
        polygon.where((p) => p.lat != null && p.lng != null).toList();
    if (validPoints.isEmpty) return null;
    final points = validPoints.map((p) => LatLng(p.lat!, p.lng!)).toList();
    final lats = points.map((p) => p.latitude).toList();
    final lngs = points.map((p) => p.longitude).toList();
    return LocationBounds(
      minLat: lats.reduce((a, b) => a < b ? a : b),
      maxLat: lats.reduce((a, b) => a > b ? a : b),
      minLng: lngs.reduce((a, b) => a < b ? a : b),
      maxLng: lngs.reduce((a, b) => a > b ? a : b),
      customBoundary: points,
    );
  }

  LocationBounds? _buildBoundsFromRegion() {
    final polygon = _selectedRegion?.polygon;
    if (polygon == null || polygon.isEmpty) return null;
    final points = polygon
        .where((p) => p.lat != null && p.lng != null)
        .map((p) => LatLng(p.lat!, p.lng!))
        .toList();
    if (points.isEmpty) return null;
    final lats = points.map((p) => p.latitude).toList();
    final lngs = points.map((p) => p.longitude).toList();
    return LocationBounds(
      minLat: lats.reduce((a, b) => a < b ? a : b),
      maxLat: lats.reduce((a, b) => a > b ? a : b),
      minLng: lngs.reduce((a, b) => a < b ? a : b),
      maxLng: lngs.reduce((a, b) => a > b ? a : b),
      customBoundary: points,
    );
  }

  LatLng? _getCenterFromBranch() {
    final c = _selectedBranch?.center;
    if (c == null || c.lat == null || c.lng == null) return null;
    return LatLng(c.lat!, c.lng!);
  }

  LatLng? _getCenterFromRegion() {
    final polygon = _selectedRegion?.polygon;
    if (polygon == null || polygon.isEmpty) return null;
    final points = polygon
        .where((p) => p.lat != null && p.lng != null)
        .map((p) => LatLng(p.lat!, p.lng!))
        .toList();
    if (points.isEmpty) return null;
    final lats = points.map((p) => p.latitude).toList();
    final lngs = points.map((p) => p.longitude).toList();
    return LatLng(
      lats.reduce((a, b) => a + b) / lats.length,
      lngs.reduce((a, b) => a + b) / lngs.length,
    );
  }

  Future<void> _pickLocation({required bool isPickup}) async {
    final locale = AppLocalizations.of(context)!;

    if (isPickup && _selectedBranch == null) {
      _showSnackError(locale.selectDeliveryBranchFirst);
      return;
    }

    if (!isPickup && _selectedRegion == null) {
      _showSnackError(locale.selectRegionFirst);
      return;
    }

    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    final result = await context.pushNamed(
      Routes.locationPicker,
      extra: LocationPickerArgs(
        bounds: isPickup ? _buildBoundsFromBranch() : _buildBoundsFromRegion(),
        centerOverride:
            isPickup ? _getCenterFromBranch() : _getCenterFromRegion(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final address = result['address']?.toString() ??
            '${result['lat']}, ${result['lng']}';
        if (isPickup) {
          pickupController.text = address;
          _savedPickupAddress = address;
          pickup_lat = result['lat'];
          pickup_long = result['lng'];
        } else {
          dropoffController.text = address;
          _savedDropoffAddress = address;
          dropoff_lat = result['lat'];
          dropoff_long = result['lng'];
        }
      });
    }
  }

  void _showSnackError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 18),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(msg,
                style: TextStyle(
                    fontFamily: 'ThmanyahSans', fontSize: 13.sp)),
          ),
        ],
      ),
      backgroundColor: buttonRedLight,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      duration: const Duration(seconds: 3),
    ));
  }

  String _formatAddress(String address) {
    final locale = AppLocalizations.of(context)!;
    if (address.contains(',') &&
        double.tryParse(address.split(',')[0].trim()) != null) {
      return '${locale.customLocationLabel} (${address.split(',')[0].substring(0, 7)}°)';
    }
    return address;
  }

  void _showBranchBottomSheet(
      BuildContext context, SearchCubit searchCubit, AppLocalizations? locale) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxWidth: double.infinity,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (context) => BranchSelectionBottomSheet(
        branches: searchCubit.deliveryBranchesData,
        selectedBranchName: searchCubit.selectedReceiveBranch,
        locale: locale,
        onBranchSelected: (branch) {
          setState(() {
            searchCubit.selectedReceiveBranch = branch.name;
            _savedBranchName = branch.name;
            _selectedBranch = branch;
            pickupController.clear();
            _savedPickupAddress = null;
            pickup_lat = null;
            pickup_long = null;
          });
        },
      ),
    );
  }

  void _showRegionBottomSheet(
      BuildContext context, SearchCubit searchCubit, AppLocalizations? locale) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxWidth: double.infinity,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (context) => RegionSelectionBottomSheet(
        regions: searchCubit.regionsData ?? [],
        selectedRegionName: _selectedRegionCity,
        locale: locale,
        onRegionSelected: (region) {
          setState(() {
            _selectedRegion = region;
            _selectedRegionCity = region.city;
            dropoffController.clear();
            _savedDropoffAddress = null;
            dropoff_lat = null;
            dropoff_long = null;
          });
        },
      ),
    );
  }

  Future<bool> onTapValidation(BuildContext context) async {
    final locale = AppLocalizations.of(context)!;
    final searchCubit = BlocProvider.of<SearchCubit>(context);

    if (pickup_lat == null || pickup_long == null) {
      _showErrorDialog(context, locale.selectPickupLocation);
      return false;
    }
    if (dropoff_lat == null || dropoff_long == null) {
      _showErrorDialog(context, locale.selectDropoffLocation);
      return false;
    }
    if (searchCubit.selectedReceiveBranch == null) {
      _showErrorDialog(context, locale.selectDeliveryBranchMsg);
      return false;
    }
    try {
      final triggeredBranchModel = searchCubit.deliveryBranchesData.firstWhere(
        (element) => element.name == searchCubit.selectedReceiveBranch,
        orElse: () => BranchModel(),
      );
      if (triggeredBranchModel.id == null) {
        _showErrorDialog(context, locale.errorSelectingBranch);
        return false;
      }
      searchCubit.selectedReceiveModel = triggeredBranchModel;
      searchCubit.selectedDriveModel = triggeredBranchModel;
      searchCubit.dropoffLat ??= searchCubit.pickupLat;
      searchCubit.dropoffLong ??= searchCubit.pickupLong;
      await searchCubit.validateDelivery();
      return true;
    } catch (e) {
      _showErrorDialog(context, locale.errorDuringValidation);
      return false;
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    final locale = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/anim/error_anim.json',
                  height: 80.h, width: 100.w, fit: BoxFit.cover),
              SizedBox(height: 10.h),
              Text(message,
                  style: AppTypography.mainTypographyColor16(context)),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  backgroundColor: strokeMainColor(context),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  locale.ok!,
                  style: AppTypography.buttonText18(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return BlocBuilder<SearchCubit, SearchState>(
      buildWhen: (previous, current) {
        if (current is SearchLoading) {
          return context.read<SearchCubit>().deliveryBranchesData.isEmpty;
        }
        if (current is SearchSuccess ||
            current is SearchValidate ||
            current is SearchInvalid ||
            current is SearchFailed) {
          return true;
        }
        return false;
      },
      builder: (context, state) {
        final searchCubit = context.read<SearchCubit>();
        final receiveDate = searchCubit.receiveDateValue;
        final driveDate = searchCubit.driveDateValue;

        searchCubit.updateDates(receiveDate, driveDate);
        final differenceInDays = searchCubit.differenceInDays;

        if (_savedPickupAddress != null && pickupController.text.isEmpty) {
          pickupController.text = _savedPickupAddress!;
        }
        if (_savedDropoffAddress != null && dropoffController.text.isEmpty) {
          dropoffController.text = _savedDropoffAddress!;
        }
        if (_savedBranchName != null &&
            searchCubit.selectedReceiveBranch == null) {
          searchCubit.selectedReceiveBranch = _savedBranchName;
        }

        if (state is SearchLoading &&
            searchCubit.deliveryBranchesData.isEmpty) {
          return Center(child: LoadingIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.choosePickupArea,
                  style: AppTypography.headingColor22(context),
                ),
                SizedBox(height: 5.h),
                Text(
                  locale.priceCalculatedByDuration,
                  style: AppTypography.paragraphColor18(context),
                ),
                SizedBox(height: 12.h),
                _buildFloatingLabelField(
                  label: locale.selectCity,
                  value: searchCubit.selectedReceiveBranch,
                  onTap: () =>
                      _showBranchBottomSheet(context, searchCubit, locale),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () => _pickLocation(isPickup: true),
                  child: _buildActionRow(
                    mainText: locale.whereToDeliver,
                    controller: pickupController,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildFloatingLabelField(
                  label: locale.selectDropoffRegion,
                  value: _selectedRegionCity,
                  onTap: () =>
                      _showRegionBottomSheet(context, searchCubit, locale),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () => _pickLocation(isPickup: false),
                  child: _buildActionRow(
                    mainText: locale.whereToPickup,
                    controller: dropoffController,
                  ),
                ),
                SizedBox(height: 20.h),
                time_select_twoBox(context),
                SizedBox(height: 14.h),
                RentalSummaryCard(
                  receiveDate: receiveDate,
                  driveDate: driveDate,
                  differenceInDays: differenceInDays,
                ),
                SizedBox(height: 12.h),
                dashedDivider(context),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: () async {
                    if (isLoading) return;
                    setState(() => isLoading = true);
                    searchCubit.pickupLat = pickup_lat;
                    searchCubit.pickupLong = pickup_long;
                    searchCubit.dropoffLat = dropoff_lat;
                    searchCubit.dropoffLong = dropoff_long;
                    await onTapValidation(context);
                    setState(() => isLoading = false);
                  },
                  child: isLoading
                      ? Center(child: LoadingIndicator())
                      : ADGradientButton(locale.search),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingLabelField({
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTypography.headingColor18(context),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
          filled: true,
          fillColor: backgroundColor(context),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:
                BorderSide(width: 1.5.w, color: strokeGrayColor(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:
                BorderSide(width: 1.5.w, color: strokeMainColor(context)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:
                BorderSide(width: 1.5.w, color: strokeGrayColor(context)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? '',
                style: AppTypography.paragraphColor16(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: iconDefaultColor(context),
              size: 28.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required String mainText,
    required TextEditingController controller,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: backgroundColor(context),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(width: 1.5.w, color: strokeGrayColor(context)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined,
              size: 20.sp, color: iconDefaultColor(context)),
          SizedBox(width: 8.w),
          Expanded(
            child: controller.text.isNotEmpty
                ? Text(
                    _formatAddress(controller.text),
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.paragraphColor18(context),
                  )
                : Text(
                    mainText,
                    style: AppTypography.paragraphColor18(context),
                  ),
          ),
        ],
      ),
    );
  }
}
