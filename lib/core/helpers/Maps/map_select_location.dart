import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../../language/locale.dart';
import '../../../modules/widgets/components/ad_gradient_btn.dart';
import '../../../modules/widgets/components/ad_prim_text_form/ad_prim_text_form.dart';
import '../../../modules/widgets/components/appbar.dart';
import '../../constants/assets/app_colors.dart';
import '../interceptors/loading_indicator.dart';

const String googleApiKey = 'AIzaSyA1rfRh5d0HM8hZ34eL8vjgaT2zC4Vtr7o';

class LocationBounds {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;
  final List<LatLng>? customBoundary;

  const LocationBounds({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
    this.customBoundary,
  });

  LatLng get center => LatLng(
    (minLat + maxLat) / 2,
    (minLng + maxLng) / 2,
  );

  bool contains(LatLng position) {
    if (customBoundary != null && customBoundary!.isNotEmpty) {
      return _isPointInPolygon(position, customBoundary!);
    }
    return position.latitude >= minLat &&
        position.latitude <= maxLat &&
        position.longitude >= minLng &&
        position.longitude <= maxLng;
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int i = 0; i < polygon.length; i++) {
      LatLng vertex1 = polygon[i];
      LatLng vertex2 = polygon[(i + 1) % polygon.length];
      if (_rayCastIntersect(point, vertex1, vertex2)) intersectCount++;
    }
    return (intersectCount % 2) == 1;
  }

  bool _rayCastIntersect(LatLng point, LatLng vertexA, LatLng vertexB) {
    double px = point.longitude, py = point.latitude;
    double ax = vertexA.longitude, ay = vertexA.latitude;
    double bx = vertexB.longitude, by = vertexB.latitude;
    if (ay > by) {
      double t;
      t = ax;
      ax = bx;
      bx = t;
      t = ay;
      ay = by;
      by = t;
    }
    if (py == ay || py == by) py += 0.00000001;
    if (py < ay || py > by || px >= (ax > bx ? ax : bx)) return false;
    if (px < (ax < bx ? ax : bx)) return true;
    double red = (py - ay) / (px - ax);
    double blue = (by - ay) / (bx - ax);
    return red >= blue;
  }

  List<LatLng> get boundaryPoints {
    if (customBoundary != null && customBoundary!.isNotEmpty) {
      return customBoundary!;
    }
    return [
      LatLng(minLat, minLng),
      LatLng(minLat, maxLng),
      LatLng(maxLat, maxLng),
      LatLng(maxLat, minLng),
    ];
  }

  /// بناء LocationBounds من polygon الـ branch مباشرةً
  static LocationBounds? fromBranchPolygon({
    required List<Map<String, double>> polygon,
  }) {
    if (polygon.isEmpty) return null;

    final points =
    polygon.map((p) => LatLng(p['lat']!, p['lng']!)).toList();

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
}

class LocationPickerFull extends StatefulWidget {
  final LatLng? initialLocation;
  final double? searchRadius;
  final LocationBounds? bounds;

  final LatLng? centerOverride;

  const LocationPickerFull({
    Key? key,
    this.initialLocation,
    this.searchRadius,
    this.bounds,
    this.centerOverride,
  }) : super(key: key);

  @override
  _LocationPickerFullState createState() => _LocationPickerFullState();
}

class _LocationPickerFullState extends State<LocationPickerFull>
    with SingleTickerProviderStateMixin {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  LatLng? _initialPosition;
  Set<Polygon> _polygons = {};
  bool _isSearching = false;
  bool _isConfirming = false;
  late AnimationController _panelAnim;
  late Animation<double> _panelSlide;

  Timer? _debounceTimer;

  AppLocalizations get locale => AppLocalizations.of(context)!;

  bool _isWithinBoundary(LatLng pos) =>
      widget.bounds == null || widget.bounds!.contains(pos);

  @override
  void initState() {
    super.initState();
    _panelAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _panelSlide =
        CurvedAnimation(parent: _panelAnim, curve: Curves.easeOutCubic);
    _panelAnim.forward();
    _searchController.addListener(_onSearchChanged);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _panelAnim.dispose();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();

    if (_searchController.text.trim().isEmpty) {
      setState(() => _searchResults.clear());
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 600), _searchLocation);
  }

  Future<void> _getCurrentLocation() async {
    if (widget.bounds != null) {
      setState(() {
        // ✅ centerOverride (من الـ API) له الأولوية، وإلا يتحسب من الـ bounds
        _initialPosition = widget.centerOverride ?? widget.bounds!.center;

        _polygons.add(Polygon(
          polygonId: const PolygonId('boundary'),
          points: widget.bounds!.boundaryPoints,
          strokeColor: const Color(0xFF00323A),
          strokeWidth: 2,
          fillColor: const Color(0xFF00323A).withValues(alpha: 0.06),
        ));
      });
      return;
    }

    if (widget.initialLocation != null) {
      setState(() => _initialPosition = widget.initialLocation);
      return;
    }

    bool svcEnabled = await Geolocator.isLocationServiceEnabled();
    if (!svcEnabled) {
      await Geolocator.openLocationSettings();
      setState(() => _initialPosition = const LatLng(24.7136, 46.6753));
      return;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        setState(() => _initialPosition = const LatLng(24.7136, 46.6753));
        return;
      }
    }

    try {
      Position pos = await Geolocator.getCurrentPosition();
      setState(() => _initialPosition = LatLng(pos.latitude, pos.longitude));
    } catch (_) {
      setState(() => _initialPosition = const LatLng(24.7136, 46.6753));
    }
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => _isSearching = true);

    String bias = '';
    if (widget.bounds != null) {
      // ✅ استخدم centerOverride للـ bias في البحث كمان
      final LatLng c = widget.centerOverride ?? widget.bounds!.center;
      bias = '&location=${c.latitude},${c.longitude}&radius=50000';
    } else if (widget.initialLocation != null) {
      double r = widget.searchRadius ?? 10000;
      bias =
      '&location=${widget.initialLocation!.latitude},${widget.initialLocation!.longitude}&radius=$r';
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=${Uri.encodeComponent(query)}&key=$googleApiKey&language=ar$bias';

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() => _searchResults = data['results'] ?? []);
      } else {
        _showError(locale.error ?? 'Error');
      }
    } catch (_) {
      _showError(locale.error ?? 'Error');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _selectSearchResult(dynamic result) async {
    final loc = result['geometry']['location'];
    final latLng = LatLng(loc['lat'], loc['lng']);
     if (!_isWithinBoundary(latLng)) {
      _showError('❌  خارج حدود المنطقة ');
      return;
    }

    _searchController.removeListener(_onSearchChanged);
    setState(() {
      _selectedLocation = latLng;
      _searchResults.clear();
      _searchController.text = result['name'];
    });
    _searchController.addListener(_onSearchChanged);
    FocusScope.of(context).unfocus();
    await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 15));
  }

  void _onMapTap(LatLng pos) {
    // ✅ رفض أي tap خارج حدود الـ polygon
    if (!_isWithinBoundary(pos)) {
      _showError('❌ ${locale.selectRegion ?? 'Outside specified area'}');
      return;
    }
    setState(() {
      _selectedLocation = pos;
      _searchResults.clear();
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _confirmLocation() async {
    final locationToUse = _selectedLocation ?? _initialPosition;
    if (locationToUse == null) {
      _showError(locale.someDataNotComplete);
      return;
    }
    if (!_isWithinBoundary(locationToUse)) {
      _showError('❌ ${locale.selectRegionAndBranch}');
      return;
    }
    setState(() => _isConfirming = true);
    String? address = await _getAddressFromGeocoding(locationToUse);
    address ??= await _getAddressFromPlaces(locationToUse);
    address ??=
    '${locationToUse.latitude.toStringAsFixed(6)}, ${locationToUse.longitude.toStringAsFixed(6)}';
    setState(() => _isConfirming = false);
    Navigator.pop(context, {
      'address': address,
      'lat': locationToUse.latitude,
      'lng': locationToUse.longitude,
    });
  }

  Future<String?> _getAddressFromGeocoding(LatLng loc) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${loc.latitude},${loc.longitude}&key=$googleApiKey&language=ar';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _getAddressFromPlaces(LatLng loc) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${loc.latitude},${loc.longitude}&radius=50&key=$googleApiKey&language=ar';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
          return data['results'][0]['vicinity'] ?? data['results'][0]['name'];
        }
      }
    } catch (_) {}
    return null;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(msg,
                style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic', fontSize: 13.sp)),
          ),
        ],
      ),
      backgroundColor: buttonRedLight,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = _selectedLocation != null;

    return Scaffold(
      appBar: CustomAppBar(
        title: locale.selectLocation,
        showBackButton: true,
      ),
      body: _initialPosition == null
          ? _buildLoader()
          : Stack(
        children: [
          GoogleMap(
            onMapCreated: (c) => _mapController = c,
            initialCameraPosition: CameraPosition(
              // ✅ _initialPosition = centerOverride أو bounds.center
              target: _initialPosition!,
              zoom: widget.bounds != null ? 12.w : 14.w,
            ),
            myLocationEnabled: widget.bounds == null,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: _onMapTap,
            polygons: _polygons,
            markers: hasSelection
                ? {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
              )
            }
                : {},
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 14.h,
            left: 16.w,
            right: 16.w,
            child: _buildSearchBar(),
          ),
          if (_searchResults.isNotEmpty)
            Positioned(
              top: 86.h,
              left: 16.w,
              right: 16.w,
              bottom: 100.h,
              child: _buildSearchResults(),
            ),
          if (widget.bounds == null)
            Positioned(
              bottom: 110.h,
              right: 16.w,
              child: _buildLocationFab(),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(_panelSlide),
              child: _buildBottomPanel(hasSelection),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ADPrimTextForm(
        controller: _searchController,
        type: TextInputType.text,
        label: locale.searchLocation ?? 'Search Location',
        pIcon: Icons.search_rounded,
        sIcon: _isSearching
            ? null
            : (_searchController.text.isNotEmpty
            ? Icons.close_rounded
            : null),
        sOnTap: _searchController.text.isNotEmpty
            ? () {
          _searchController.clear();
          setState(() => _searchResults.clear());
        }
            : null,
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isSearching)
              LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: Colors.transparent,
                color: iconDefaultColor(context),
              ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Colors.grey.shade100,
                  indent: 52.w,
                ),
                itemBuilder: (context, i) {
                  final r = _searchResults[i];
                  return ListTile(
                    dense: true,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
                    leading: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: iconDefaultColor(context).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.location_on_rounded,
                          color: iconDefaultColor(context), size: 18.sp),
                    ),
                    title: Text(
                      r['name'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: headingColor(context),
                      ),
                    ),
                    subtitle: Text(
                      r['formatted_address'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    onTap: () => _selectSearchResult(r),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationFab() {
    return GestureDetector(
      onTap: () async {
        await _getCurrentLocation();
        if (_initialPosition != null) {
          _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(_initialPosition!, 15));
        }
      },
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.my_location_rounded,
            color: iconDefaultColor(context), size: 22.sp),
      ),
    );
  }

  Widget _buildBottomPanel(bool hasSelection) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 14.h),
            decoration: BoxDecoration(
              color: strokeGrayColor(context),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          GestureDetector(
            onTap: _isConfirming ? null : _confirmLocation,
            child: _isConfirming
                ? SizedBox(
              height: 50.h,
              child: Center(child: LoadingIndicator()),
            )
                : ADGradientButton(
              locale.confirm,
              icon: Icons.check_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
              color: iconDefaultColor(context), strokeWidth: 2.5.w),
          SizedBox(height: 16.h),
          Text(
            locale.loading,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 13.sp,
              color: mainTypographyColor(context),
            ),
          ),
        ],
      ),
    );
  }
}