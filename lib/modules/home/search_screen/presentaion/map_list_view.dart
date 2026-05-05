import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/all_branching/data/models/branch_model.dart';
import 'package:darbak/modules/home/search_screen/data/models/areas_model.dart';
import 'package:darbak/modules/home/search_screen/presentaion/widget/location_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/components/appbar.dart';

class MapListView extends StatefulWidget {
  final List<BranchModel>? branches;
  final bool isReceive;
  final List<AreasModel>? areas;
  final bool isAutomated;

  const MapListView({
    Key? key,
    required this.branches,
    required this.isReceive,
    required this.areas,
    required this.isAutomated,
  }) : super(key: key);

  @override
  State<MapListView> createState() => _MapListViewState();
}

class _MapListViewState extends State<MapListView> {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: locale!.selectBranch.toString(),
        showBackButton: true,
      ),
      body: LocationListView(
        branches: widget.branches!,
        isReceive: widget.isReceive,
        isAutomated: widget.isAutomated,
        areas: widget.areas,
      ),
    );
  }
}