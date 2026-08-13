import 'package:auto_size_text/auto_size_text.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/all_branching/bloc/all_branching_cubit.dart';
import 'package:darbak/modules/home/all_branching/bloc/all_branching_state.dart';
import 'package:darbak/modules/home/all_branching/page/view_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
 import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import '../../../../core/constants/assets/app_colors.dart';
import '../../../widgets/components/ad_gradient_btn.dart';
import '../../../widgets/components/ad_prim_text_form/ad_prim_text_form.dart';
import '../../../widgets/components/appbar.dart';
import '../../search_screen/presentaion/widget/shimmer_list.dart';
import '../data/models/branch_model.dart';
import 'package:darbak/service_locator.dart';
class BranchesScreen extends StatefulWidget {
  const BranchesScreen({Key? key}) : super(key: key);

  static Widget entry() => BlocProvider<AllBranchCubit>(
        create: (_) => sl<AllBranchCubit>(),
        child: const BranchesScreen(),
      );

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  TextEditingController _searchController = TextEditingController();
  List<BranchModel> _filteredBranches = [];
  List<BranchModel> _allBranches = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AllBranchCubit>(context).getAllBranch();

    _filteredBranches = _allBranches;
    _searchController.addListener(_filterBranches);
  }

  void _filterBranches() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBranches = _allBranches;
      } else {
        _filteredBranches = _allBranches
            .where((branch) => branch.name!.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor(context),
        appBar: CustomAppBar(
          title: locale!.branches.toString(),
          showBackButton: true,
          // showThemeToggle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            // Force refresh from server
            await BlocProvider.of<AllBranchCubit>(context).refreshBranches();
          },
          child: BlocConsumer<AllBranchCubit, AllBranchState>(
            listener: (context, state) {
              if (state is AllBranchLoaded) {
                _allBranches = state.branchModel;
                _filteredBranches = _allBranches;
              }
            },
            builder: (context, state) {
              if (state is AllBranchLoading) {
                return ShimmerLoadingList();
              }

              if (state is AllBranchError) {
                return _buildErrorState(context, state.error, locale);
              }

              if (state is AllBranchLoaded) {
                return Column(
                  children: [
                    // Search bar
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      child: ADPrimTextForm(
                        auth: true,
                        controller: _searchController,
                        type: TextInputType.name,
                        label: locale.exploreOurBranches,
                        pIcon: Icons.search_outlined,
                      ),
                    ),

                    // Branches list
                    Expanded(
                      child: _filteredBranches.isEmpty
                          ? _buildEmptyState(locale, context)
                          : _buildBranchesList(state, locale, context),
                    ),
                  ],
                );
              }

              return Container();
            },
          ),
        ),
      ),
    );
  }
  Widget _buildErrorState(
      BuildContext context, String error, AppLocalizations locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            error,
            style: AppTypography.paragraphColor16(context),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<AllBranchCubit>(context).getAllBranch();
            },
            child: Text(
                locale.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations locale, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            "assets/anim/search_empty.json",
            height: 220.h,
            width: 220.w,
          ),
          Text(
            locale.noBranchWithThisName,
            style: AppTypography.paragraphColor16(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchesList(
      AllBranchState state, AppLocalizations locale, BuildContext context) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: _filteredBranches.length,
      itemBuilder: (context, index) {
        final branch = _filteredBranches[index];
        final isRTL = locale.isDirectionRTL(context);

        return Container(
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
            crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Branch name
              Row(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Image.asset(
                    "assets/icons/new_branch.png",
                    height: 27.h,
                    width: 27.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: AutoSizeText(
                      branch.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.mainTypographyColor16(context),
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                ],
              ),

              // Region
              Row(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Image.asset(
                    "assets/icons/new_branch_2.png",
                    height: 27.h,
                    width: 27.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Row(
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        Text(
                          "${locale.region.toString()} : ",
                          style: AppTypography.paragraphColor14(context),
                        ),
                        Flexible(
                          child: Text(
                            "${branch.region}",
                            style: AppTypography.headingColor14(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Address
              Row(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Image.asset(
                    "assets/icons/new_branch_2.png",
                    height: 27.h,
                    width: 27.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      branch.address ?? '',
                      style: AppTypography.headingColor14(context),
                      overflow: TextOverflow.visible,
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                ],
              ),

              // Work Time
              if (branch.workTime?.openAllDays == 1) ...[
                Row(
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    Image.asset(
                      "assets/icons/new_clock.png",
                      height: 27.h,
                      width: 27.w,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Row(
                        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          Text(
                            "${locale.workTime} : ",
                            style: AppTypography.paragraphColor14(context),
                          ),
                          Text(
                            "24 ${locale.hour}",
                            style: AppTypography.headingColor14(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    Image.asset(
                      "assets/icons/new_clock.png",
                      height: 27.h,
                      width: 27.w,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Row(
                        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          Text(
                            "${locale.morning.toString()} : ",
                            style: AppTypography.paragraphColor14(context),
                          ),
                          Flexible(
                            child: Text(
                              "${branch.workTime?.alldays?.morning?.timeopen ?? ''} - ${branch.workTime?.alldays?.morning?.timeclose ?? ''}",
                              style: AppTypography.headingColor14(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (branch.workTime?.alldays?.period != 0)
                  Row(
                    textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Image.asset(
                        "assets/icons/new_clock.png",
                        height: 27.h,
                        width: 27.w,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Row(
                          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Text(
                              "${locale.afternoon.toString()} : ",
                              style: AppTypography.paragraphColor14(context),
                            ),
                            Flexible(
                              child: Text(
                                "${branch.workTime?.alldays?.afternone?.timeopen ?? ''} ${locale.toTime} ${branch.workTime?.alldays?.afternone?.timeclose ?? ''}",
                                style: AppTypography.headingColor14(context),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],

              SizedBox(height: 4.h),

              // Action Buttons
              Row(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
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
                      child: ADGradientButton(
                        locale.callUs,
                        border: Border.all(color: iconDefaultColor(context),width: 2.w),
                        icon: Icons.phone,
                        backgroundColor: backgroundColor(context),
                        iconSize: 20.sp,
                        textStyle: AppTypography.buttonText15(context),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: InkWell(
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
                                isRTL ? 'الموقع غير متوفر' : 'Location not available',
                              ),
                            ),
                          );
                        }
                      },
                      child: ADGradientButton(
                        backgroundColor: buttonPrimaryBgColor(context),
                        locale.LocationOnMap.toString(),
                        textStyle: AppTypography.buttonText15(context),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
