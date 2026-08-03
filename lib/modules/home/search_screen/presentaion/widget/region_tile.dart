import 'package:darbak/core/constants/assets/assets.dart';
import 'package:darbak/core/helpers/enums.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/home/search_screen/data/models/regions_model.dart';
import 'package:darbak/modules/widgets/components/custom_rect_tween.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/assets/app_colors.dart';

class RegionTile extends StatefulWidget {
  final List<RegionModel>? regions;
  final Function(RegionModel)? onRegionSelected;

  const RegionTile({
    Key? key,
    required this.regions,
    this.onRegionSelected,
  }) : super(key: key);

  @override
  State<RegionTile> createState() => _RegionTileState();
}

class _RegionTileState extends State<RegionTile> {
  List<bool> _isTappedList = [];

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        customDialog(context,
            regionModel: widget.regions!.toList(), receive: true);
      },
      child: Hero(
        tag: _heroTag,
        createRectTween: (begin, end) {
          return CustomRectTween(begin: begin!, end: end!);
        },
          child: Container(
            height: 55.h,
            alignment: AlignmentDirectional.centerStart,
            decoration: BoxDecoration(
              border: Border.all(color: strokeGrayColor(context), width: 2.w),
              borderRadius: BorderRadius.circular(15.r),
              color: backgroundColor(context),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Row(
                children: [
                  Image.asset(
                    Assets.img_map_region,
                    color: mainTypographyColor(context),
                    width: 35.w,
                    height: 35.h,
                  ),

                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      BlocProvider.of<SearchCubit>(context).selectedRegion ??
                          locale!.selectRegion.toString(),
                      style: AppTypography.paragraphColor18(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: mainTypographyColor(context),
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }

  Future<dynamic> customDialog(BuildContext context,
      {required List<RegionModel> regionModel, required bool receive}) {
    final local = AppLocalizations.of(context);

    return showModalBottomSheet(
      useRootNavigator: true,
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.23,
                  height: MediaQuery.of(context).size.height * 0.008,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              Row(
                children: [
                  Text(
                    local!.selectRegion.toString(),
                    style: TextStyle(
                      color: Color(0xFF05658F),
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.008,
              ),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height / 3),
                  crossAxisCount: 3,
                  crossAxisSpacing: 3.0.sp,
                  mainAxisSpacing: 7.0.sp,
                ),
                itemCount: widget.regions!.length.toInt(),
                itemBuilder: (context, index) {
                  if (_isTappedList.length <= index) {
                    _isTappedList.add(false);
                  }
                  return Bounce(
                    onTap: () {
                      final selectedRegion = widget.regions![index];

                      BlocProvider.of<SearchCubit>(context).selectedRegion = selectedRegion.name;

                      final selectedRegionModel = BlocProvider.of<SearchCubit>(context)
                          .regionsData
                          ?.where((element) =>
                      element.name == BlocProvider.of<SearchCubit>(context).selectedRegion)
                          .first;

                      BlocProvider.of<SearchCubit>(context).rentType == RentType.classic
                          ? BlocProvider.of<SearchCubit>(context)
                          .getBranches(regionId: selectedRegionModel!.id ?? 0)
                          : BlocProvider.of<SearchCubit>(context)
                          .getAreas(regionId: selectedRegionModel?.id);

                      widget.onRegionSelected?.call(selectedRegion);
                      Navigator.pop(context);
                    },                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Color(0xffFDFDFD).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Color(0xFF05658F),
                          width: 2.w,
                        ),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              Assets.icon_areaLocation,
                              color: Theme.of(context).brightness ==
                                  Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            Flexible(
                              child: Text(
                                widget.regions![index].name.toString(),
                                style: GoogleFonts.almarai(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).brightness ==
                                        Brightness.light
                                        ? Colors.black
                                        : Colors.white),
                              ),
                            ),
                          ]),
                    ),
                  );
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const String _heroTag = 'Hero-Tag';

class _PopupCard extends StatefulWidget {
  final List<RegionModel>? regions;

  const _PopupCard({Key? key, required this.regions}) : super(key: key);

  @override
  State<_PopupCard> createState() => _PopupCardState();
}

class _PopupCardState extends State<_PopupCard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: _heroTag,
          createRectTween: (begin, end) =>
              CustomRectTween(begin: begin!, end: end!),
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            elevation: 2,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...widget.regions!
                        .map(
                          (region) => SelectionTile(
                          text: region.name ?? "",
                          onTap: () {
                            setState(() =>
                            BlocProvider.of<SearchCubit>(context)
                                .selectedRegion = region.name);
                            final selectedRegionModel =
                                BlocProvider.of<SearchCubit>(context)
                                    .regionsData
                                    ?.where((element) =>
                                element.name ==
                                    BlocProvider.of<SearchCubit>(
                                        context)
                                        .selectedRegion)
                                    .first;
                            BlocProvider.of<SearchCubit>(context)
                                .selectedReceiveBranch = null;
                            BlocProvider.of<SearchCubit>(context)
                                .selectedDriveBranch = null;
                            BlocProvider.of<SearchCubit>(context)
                                .rentType ==
                                RentType.classic
                                ? BlocProvider.of<SearchCubit>(context)
                                .getBranches(
                                regionId:
                                selectedRegionModel!.id ?? 0)
                                : BlocProvider.of<SearchCubit>(context)
                                .getAreas(
                                regionId: selectedRegionModel?.id);
                            Navigator.pop(context);
                          }),
                    )
                        .toList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SelectionTile extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const SelectionTile({
    Key? key,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: TextButton(
          onPressed: onTap,
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 15.sp,
            ),
          )),
    );
  }
}