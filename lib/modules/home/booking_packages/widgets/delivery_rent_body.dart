import 'package:flutter/cupertino.dart';
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
import '../../all_branching/data/models/branch_model.dart' show BranchModel;
import '../../search_screen/blocs/search_bloc/search_cubit.dart';
import '../../search_screen/blocs/search_bloc/search_state.dart';
import '../../search_screen/presentaion/widget/rental_summary_card.dart';
import 'package:darbak/service_locator.dart';
import '../../../location/data/location_repository.dart';
import '../../../location/data/models/branch.dart';
import '../../../location/data/models/region.dart';
import '../../../location/presentaion/bloc/location_selection_cubit.dart';
import '../../../location/presentaion/bloc/location_selection_state.dart';
import '../../../location/presentaion/pages/branch_picker_screen.dart';

/// Delivery's branch picking, per specs/001-region-branch-selection/tasks.md
/// T047-T048. Reads [LocationSelectionCubit] only for the delivery-capable
/// branch list (screen-scoped, `registerFactory`, started with
/// `LocationFilter.delivery()` — no region step) — mirroring
/// `DailyRentBody`'s pattern from T035-T040 for the branch half only, since
/// this flow has no dropoff branch concept, only a dropoff *location*.
///
/// The dropoff/pickup **map location** picking below (`_buildBoundsFrom...`,
/// `_getCenterFrom...`, `_pickLocation`) is the out-of-scope AREAS FEATURE
/// (BD-1) and is preserved byte-for-byte in behaviour — only repointed at
/// the new [Branch.polygon]/[Branch.center] and [Region.polygon], which
/// carry the identical `{lat, lng}` shape the old `BranchModel`/`RegionModel`
/// geometry did. The region used to bound the dropoff map picker is NOT a
/// "region step" for branch filtering (delivery has none) — it is fetched
/// directly from [LocationRepository] (bypassing the cubit, which never
/// fetches regions for a direct filter) purely to keep this out-of-scope
/// map feature working.
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

  Region? _selectedRegion;
  String? _selectedRegionCity;
  List<Region> _boundsRegions = const [];

  String? _savedPickupAddress;
  String? _savedDropoffAddress;

  @override
  void initState() {
    super.initState();
    _loadBoundsRegions();
  }

  /// Best-effort, out-of-scope areas-feature support only. A failure here
  /// leaves `_boundsRegions` empty, which the region picker below already
  /// renders as its own empty state — the branch list itself never depends
  /// on this call.
  Future<void> _loadBoundsRegions() async {
    try {
      final regions = await sl<LocationRepository>().getRegions();
      final withPolygon =
          regions.where((r) => r.polygon != null && r.polygon!.isNotEmpty).toList();
      if (mounted) setState(() => _boundsRegions = withPolygon);
    } catch (_) {
      // Areas feature stays best-effort here, same as before this rewrite.
    }
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
      _showSnackError(AppLocalizations.of(context)!.locationServiceDisabled);
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

  LocationBounds? _buildBoundsFromBranch(Branch? branch) {
    final polygon = branch?.polygon;
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

  LatLng? _getCenterFromBranch(Branch? branch) {
    final c = branch?.center;
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

  Future<void> _pickLocation({required bool isPickup, required Branch? pickupBranch}) async {
    final locale = AppLocalizations.of(context)!;

    if (isPickup && pickupBranch == null) {
      _showSnackError(locale.selectDeliveryBranchFirst);
      return;
    }

    if (!isPickup && _selectedRegion == null) {
      _showSnackError(locale.selectRegionFirst);
      return;
    }

    final bounds =
        isPickup ? _buildBoundsFromBranch(pickupBranch) : _buildBoundsFromRegion();

    if (bounds == null) {
      bool hasPermission = await _checkLocationPermission();
      if (!hasPermission) return;
    }

    final result = await context.pushNamed(
      Routes.locationPicker,
      extra: LocationPickerArgs(
        bounds: bounds,
        centerOverride:
            isPickup ? _getCenterFromBranch(pickupBranch) : _getCenterFromRegion(),
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

  Future<void> _pickBranch(
    BuildContext context,
    LocationSelectionCubit cubit,
    List<Branch> options,
    int? selectedId,
  ) async {
    // NOT PersistentNavBarNavigator.pushNewScreen<Branch>(...) — see
    // contracts/navigation-contract.md: that helper throws at runtime for a
    // typed generic. Pushing directly on the root Navigator keeps the same
    // "outside the caller's provider subtree" placement Principle II
    // requires.
    final emptyMessage = AppLocalizations.of(context)!.noBranchesOfferService;
    final picked = await Navigator.of(context, rootNavigator: true).push<Branch>(
      CupertinoPageRoute<Branch>(
        builder: (_) => BranchPickerScreen(
          branches: options,
          selectedId: selectedId,
          emptyMessage: emptyMessage,
        ),
      ),
    );
    if (picked == null) return;
    cubit.setPickupBranch(picked);
    setState(() {
      pickupController.clear();
      _savedPickupAddress = null;
      pickup_lat = null;
      pickup_long = null;
    });
  }

  Future<void> _showRegionPicker(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return showModalBottomSheet(
      useRootNavigator: true,
      backgroundColor: backgroundColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      isScrollControlled: true,
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: strokeGrayColor(sheetContext),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          locale.selectDropoffRegion,
                          style: AppTypography.headingColor18(sheetContext),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(sheetContext),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: bg2Color(sheetContext),
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Icon(Icons.close,
                            size: 20.sp, color: headingColor(sheetContext)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 420.h),
                child: _boundsRegions.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 24.h),
                        child: Text(
                          locale.noBranchesToShow,
                          style: AppTypography.paragraphColor14(sheetContext),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _boundsRegions.length,
                        itemBuilder: (context, index) {
                          final region = _boundsRegions[index];
                          final isSelected = region.id == _selectedRegion?.id;
                          return ListTile(
                            title: Text(
                              region.city ?? region.name,
                              style: AppTypography.paragraphColor16(sheetContext),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle,
                                    color: mainTypographyColor(sheetContext))
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedRegion = region;
                                _selectedRegionCity = region.city;
                                dropoffController.clear();
                                _savedDropoffAddress = null;
                                dropoff_lat = null;
                                dropoff_long = null;
                              });
                              Navigator.pop(sheetContext);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> onTapValidation(BuildContext context, Branch? pickupBranch) async {
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
    if (pickupBranch == null) {
      _showErrorDialog(context, locale.selectDeliveryBranchMsg);
      return false;
    }
    try {
      // Bridge into the legacy BranchModel the still-unconverted downstream
      // flow (FilterModel, CarsInformation, ...) expects. Only `id`/`name`
      // are ever read from it there — both come straight from the new
      // Branch, never re-resolved by matching a name (Principle I).
      final bridge = BranchModel(id: pickupBranch.id, name: pickupBranch.name);
      searchCubit.selectedReceiveModel = bridge;
      searchCubit.selectedDriveModel = bridge;
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
        if (current is SearchSuccess ||
            current is SearchValidate ||
            current is SearchInvalid ||
            current is SearchFailed) {
          return true;
        }
        return false;
      },
      builder: (context, searchState) {
        return BlocBuilder<LocationSelectionCubit, LocationSelectionState>(
          builder: (context, locState) {
            final cubit = context.read<LocationSelectionCubit>();
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

            if (locState.status == LocationSelectionStatus.loading &&
                locState.pickupOptions.isEmpty) {
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

                // FR-038 failure UI, alongside the normal selection rows,
                // never instead of them — the cubit never discards
                // pickupBranch on fetch failure.
                if (locState.status == LocationSelectionStatus.failure)
                  _FailureBanner(
                    message: locState.error ?? '',
                    onRetry: cubit.retry,
                  ),

                _buildFloatingLabelField(
                  label: locale.selectCity,
                  value: locState.pickupBranch?.name,
                  onTap: () => _pickBranch(
                    context,
                    cubit,
                    locState.pickupOptions,
                    locState.pickupBranch?.id,
                  ),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () => _pickLocation(
                      isPickup: true, pickupBranch: locState.pickupBranch),
                  child: _buildActionRow(
                    mainText: locale.whereToDeliver,
                    controller: pickupController,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildFloatingLabelField(
                  label: locale.selectDropoffRegion,
                  value: _selectedRegionCity,
                  onTap: () => _showRegionPicker(context),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () => _pickLocation(
                      isPickup: false, pickupBranch: locState.pickupBranch),
                  child: _buildActionRow(
                    mainText: locale.whereToPickup,
                    controller: dropoffController,
                  ),
                ),
                SizedBox(height: 20.h),
                const TimeSelectTwoBox(),
                SizedBox(height: 14.h),
                Center(child: RentalSummaryCard(differenceInDays: differenceInDays,)),

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
                    await onTapValidation(context, locState.pickupBranch);
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

/// FR-038: shown alongside the normal selection UI, never instead of it.
class _FailureBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FailureBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bg2Color(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: buttonRedColor(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(message, style: AppTypography.paragraphColor14(context)),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              locale.retry,
              style: AppTypography.paragraphColor14(context)
                  .copyWith(color: buttonBlueColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}
