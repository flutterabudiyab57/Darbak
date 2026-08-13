import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/all_branching/data/models/branch_model.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/style/style.dart';
import '../../../../widgets/components/ad_gradient_btn.dart';
import '../../../../widgets/components/ad_prim_text_form/ad_prim_text_form.dart';
import '../../../all_branching/bloc/all_branching_cubit.dart';
import '../../../all_branching/page/text_tile_branch.dart';
import '../../../all_branching/page/view_location.dart';

class BranchesListView extends StatefulWidget {
  final List<BranchModel> branches;
  final bool isReceive;

  const BranchesListView({
    Key? key,
    required this.branches,
    required this.isReceive,
  }) : super(key: key);

  @override
  State<BranchesListView> createState() => _BranchesListViewState();
}

class _BranchesListViewState extends State<BranchesListView> {
  final TextEditingController _searchController = TextEditingController();
  List<BranchModel> filteredBranches = [];

  @override
  void initState() {
    super.initState();
    filteredBranches = widget.branches;
    _searchController.addListener(_filterBranches);
  }

  void _filterBranches() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredBranches = widget.branches
          .where((branch) => branch.name!.toLowerCase().contains(query))
          .toList();
    });
  }

  void _selectBranch(BranchModel branch) {
    final fallbackBranch = BranchModel(name: 'Default Branch');

    final selectedBranch = widget.isReceive
        ? branch
        : context.read<AllBranchCubit>().branchesData.firstWhere(
          (b) => b.name == branch.name,
      orElse: () => fallbackBranch,
    );

    if (widget.isReceive) {
      BlocProvider.of<SearchCubit>(context).selectedReceiveBranch =
          selectedBranch.name;
      BlocProvider.of<SearchCubit>(context).selectedReceiveModel =
          BlocProvider.of<SearchCubit>(context).branchesData.firstWhere(
                (b) => b.name == selectedBranch.name,
            orElse: () => fallbackBranch,
          );
    } else {
      BlocProvider.of<SearchCubit>(context).selectedDriveBranch =
          selectedBranch.name;
      BlocProvider.of<SearchCubit>(context).selectedReceiveModel =
          context.read<AllBranchCubit>().branchesData.firstWhere(
                (b) => b.name == selectedBranch.name,
            orElse: () => fallbackBranch,
          );
    }

    if (BlocProvider.of<SearchCubit>(context).selectedReceiveModel !=
        fallbackBranch) {
      BlocProvider.of<SearchCubit>(context).changeState();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Column(
      children: [
        // Search Container
        Padding(
          padding: EdgeInsets.all(8.sp),
          child: SizedBox(
            child: ADPrimTextForm(
              controller: _searchController,
              type: TextInputType.text,
              label: locale!.search.toString(),
              pIcon: Icons.search,
            ),
          ),
        ),
        // List of Branches
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            itemCount: filteredBranches.length,
            itemBuilder: (context, index) {
              final branch = filteredBranches[index];
              return Bounce(
                onTap: () {
                  _selectBranch(branch);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    color: buttonWhiteColor(context),
                    border: Border.all(
                      color: strokeGrayColor(context),
                      width: 2.w,
                    ),
                  ),
                  child: Column(
                    spacing: 12.h,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Branch name
                      Row(
                        children: [
                          Image.asset(
                            "assets/icons/new_branch.png",
                            height: 27.h,
                            width: 27.w,
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.025),
                          Expanded(
                            child: AutoSizeText(
                              " ${branch.name} ",
                              style: AppTypography.mainTypographyColor16(context),
                            ),
                          ),
                        ],
                      ),
                      SingleChildScrollView(
                        child: Column(
                          spacing: 12.h,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Address
                            Row(
                              children: [
                                Image.asset(
                                  "assets/icons/new_branch_2.png",
                                  height: 27.h,
                                  width: 27.w,
                                ),
                                Expanded(
                                  child: Text(
                                    "  ${branch.address}",
                                    style: AppTypography.headingColor14(context),
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),

                             Row(
                              children: [
                                Image.asset(
                                  "assets/icons/new_clock.png",
                                  height: 27.h,
                                  width: 27.w,
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.025),
                                FittedBox(
                                  child: TextTileBranch(
                                    content:
                                    "${branch.workTime?.alldays?.morning?.timeopen ?? ''} - ${branch.workTime?.alldays?.morning?.timeclose ?? ''}${branch.workTime?.alldays?.afternone?.timeopen != null ? ' - ${branch.workTime?.alldays?.afternone?.timeopen} - ${branch.workTime?.alldays?.afternone?.timeclose ?? ''}' : ''}",
                                    title: "${locale.allDays} :",
                                  ),
                                ),
                              ],
                            ),
                             Row(
                              children: [
                                Image.asset(
                                  "assets/icons/new_clock.png",
                                  height: 27.h,
                                  width: 27.w,
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.025),
                                FittedBox(
                                  child: TextTileBranch(
                                    content:
                                    "${branch.workTime?.fri?.morning?.timeopen ?? ''} - ${branch.workTime?.fri?.morning?.timeclose ?? ''}",
                                    title: "${locale.fri} :",
                                  ),
                                ),
                              ],
                            ),
                             Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(15.r),
                                  onTap: () async {
                                    final Uri telUri = Uri(
                                      scheme: 'tel',
                                      path: branch.phone,
                                    );

                                    if (await UrlLauncher.canLaunchUrl(telUri)) {
                                      await UrlLauncher.launchUrl(telUri);
                                    } else {
                                      print('Could not launch ${telUri.toString()}');
                                    }
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.40,
                                    child: ADGradientButton(
                                      locale.callUs.toString(),
                                      backgroundColor: buttonPrimaryBgColor(context),
                                      icon: Icons.phone,
                                      iconSize: 20.sp,
                                      textStyle: AppTypography.buttonText15(context),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(15.r),
                                  onTap: () {
                                    final String? locationUrl = branch.locationUrl;

                                    if (locationUrl != null && locationUrl.isNotEmpty) {
                                      PersistentNavBarNavigator.pushNewScreen(
                                        context,
                                        screen: ViewLocation(
                                          url: locationUrl,
                                          title: branch.name ?? locale.LocationOnMap.toString(),
                                          lat: branch.lat,
                                          long: branch.long,
                                        ),
                                        withNavBar: false,
                                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            locale.locationNotAvailable,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.42,
                                    child: ADGradientButton(
                                      backgroundColor: buttonPrimaryBgColor(context),
                                      locale.LocationOnMap.toString(),
                                      textStyle: AppTypography.buttonText15(context),
                                      icon: Icons.arrow_forward_ios_rounded,
                                      iconSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
              },
          ),
        ),
      ],
    );
  }
}
