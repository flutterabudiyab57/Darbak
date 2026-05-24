import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../widgets/components/appbar.dart';

class ViewLocation extends StatefulWidget {
  const ViewLocation({
    Key? key,
    required this.url,
    required this.title,
    this.lat,
    this.long,
  }) : super(key: key);

  final String? url;
  final String title;
  final String? lat;
  final String? long;

  @override
  State<ViewLocation> createState() => _ViewLocationState();
}

class _ViewLocationState extends State<ViewLocation> {
  late LatLng _branchLocation;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    // Parse coordinates
    double lat = double.tryParse(widget.lat ?? '0') ?? 0;
    double lng = double.tryParse(widget.long ?? '0') ?? 0;

    _branchLocation = LatLng(lat, lng);

    // Add marker
    _markers.add(
      Marker(
        markerId: MarkerId('branch_location'),
        position: _branchLocation,
        infoWindow: InfoWindow(
          title: widget.title,
          snippet: 'اضغط للتنقل',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
        // showThemeToggle: true,
        showBackButton: true,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _branchLocation,
          zoom: 15,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        mapToolbarEnabled: true,
        onMapCreated: (GoogleMapController controller) {},
      ),
    );
  }
}