import 'package:auto_size_text/auto_size_text.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/all_branching/page/view_location.dart';
import 'package:darbak/modules/location/data/location_filter.dart';
import 'package:darbak/modules/location/data/location_repository.dart';
import 'package:darbak/modules/location/data/models/branch.dart';
import 'package:darbak/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
 import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import '../../../../core/constants/assets/app_colors.dart';
import '../../../widgets/components/ad_gradient_btn.dart';
import '../../../widgets/components/ad_prim_text_form/ad_prim_text_form.dart';
import '../../../widgets/components/appbar.dart';
import '../../search_screen/presentaion/widget/shimmer_list.dart';

enum _LoadState { loading, loaded, error }

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({Key? key}) : super(key: key);

  static Widget entry() => const BranchesScreen();

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Branch> _filteredBranches = [];
  List<Branch> _allBranches = [];
  _LoadState _loadState = _LoadState.loading;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadBranches();
    _searchController.addListener(_filterBranches);
  }

  Future<void> _loadBranches({bool forceRefresh = false}) async {
    setState(() {
      _loadState = _LoadState.loading;
    });
    try {
      final branches = await sl<LocationRepository>()
          .getBranches(const LocationFilter.allRegions(), forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _allBranches = branches;
        _filterBranches();
        _loadState = _LoadState.loaded;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loadState = _LoadState.error;
      });
    }
  }

  void _filterBranches() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBranches = _allBranches;
      } else {
        _filteredBranches = _allBranches
            .where((branch) => branch.name.toLowerCase().contains(query))
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
          onRefresh: () => _loadBranches(forceRefresh: true),
          child: Builder(
            builder: (context) {
              if (_loadState == _LoadState.loading) {
                return ShimmerLoadingList();
              }

              if (_loadState == _LoadState.error) {
                return _buildErrorState(context, _error, locale);
              }

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
                      fillColor: bg2Color(context),
                      borderColor: Colors.transparent,
                    ),
                  ),

                  // Branches list
                  Expanded(
                    child: _filteredBranches.isEmpty
                        ? _buildEmptyState(locale, context)
                        : _buildBranchesList(locale, context),
                  ),
                ],
              );
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
            onPressed: () => _loadBranches(),
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
      AppLocalizations locale, BuildContext context) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: _filteredBranches.length,
      itemBuilder: (context, index) {
        final branch = _filteredBranches[index];
        final isRTL = locale.isDirectionRTL(context);

        final int? period = branch.workTime?.allDays?.period;
        final bool hasAfternoon = (period ?? 0) != 0;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            color: backgroundColor(context),
            border: Border.all(
              color: bg2Color(context),
              width: 1.5.w,
            ),
          ),
          child: Column(
            spacing: 15.h,
            crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              // Branch name
              Row(
                children: [
                  Flexible(
                    child: AutoSizeText(
                      branch.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.mainTypographyColor15(context),
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                  if ((branch.regionName ?? '').isNotEmpty) ...[
                    SizedBox(width: 3.w,),
                    AutoSizeText(
                      "( ${branch.regionName!} )",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.paragraphColor12(context),
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ],
                ],
              ),

              // Working hours + Address boxes
              IntrinsicHeight(
                child: Row(
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(minHeight: 97.h),
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: bg2Color(context),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          spacing: 10.h,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/new_branch_2.svg',
                              width: 28.w,
                              height: 27.h,
                              colorFilter: ColorFilter.mode(
                                iconDefaultColor(context),
                                BlendMode.srcIn,
                              ),
                            ),
                            Text(
                              branch.address ?? '',
                              style: AppTypography.headingColor12(context),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(minHeight: 97.h),
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: bg2Color(context),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          spacing: 10.h,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/new_clock.svg',
                              width: 28.w,
                              height: 27.h,
                              colorFilter: ColorFilter.mode(
                                iconDefaultColor(context),
                                BlendMode.srcIn,
                              ),
                            ),
                            Column(
                              spacing: 6.h,
                              children: [
                                if (branch.workTime?.openAllDays == true)
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "${locale.workTime} : ",
                                          style: AppTypography.headingColor12Bold(context),
                                        ),
                                        TextSpan(
                                          text: "24 ${locale.hour}",
                                          style: AppTypography.headingColor12(context),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                else ...[
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "${locale.morning} : ",
                                          style: AppTypography.headingColor12Bold(context),
                                        ),
                                        TextSpan(
                                          text: "${branch.workTime?.allDays?.morning?.open ?? ''} - ${branch.workTime?.allDays?.morning?.close ?? ''}",
                                          style: AppTypography.headingColor12(context),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (hasAfternoon)
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "${locale.afternoon} : ",
                                            style: AppTypography.headingColor12Bold(context),
                                          ),
                                          TextSpan(
                                            text: "${branch.workTime?.allDays?.afternoon?.open ?? ''} ${locale.toTime} ${branch.workTime?.allDays?.afternoon?.close ?? ''}",
                                            style: AppTypography.headingColor12(context),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15.r),
                      onTap: () async {
                        final phone = branch.phone;
                        if (phone == null || phone.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isRTL ? 'رقم الهاتف غير متوفر' : 'Phone number not available',
                              ),
                            ),
                          );
                          return;
                        }

                        final Uri telUri = Uri.parse('tel:${phone.trim()}');

                        try {
                          final launched = await UrlLauncher.launchUrl(
                            telUri,
                            mode: UrlLauncher.LaunchMode.externalApplication,
                          );
                          if (!launched) {
                            debugPrint('launchUrl returned false for $telUri');
                          }
                        } catch (e) {
                          debugPrint('tel launch failed: $e');
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isRTL ? 'تعذر بدء المكالمة' : 'Could not start the call',
                              ),
                            ),
                          );
                        }
                      },
                      child: ADGradientButton(
                        locale.callUs,
                        backgroundColor: Colors.transparent,
                        border: Border.all(color: strokeMainColor(context), width: 2.w),
                        height: 42.h,
                        textStyle: AppTypography.headingColor14Bold(context),
                        autoSize: false,
                      ),
                    ),
                  ),
                  SizedBox(width: 17.w),
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
                              title: branch.name.isNotEmpty ? branch.name : locale.LocationOnMap.toString(),
                              lat: branch.lat?.toString(),
                              long: branch.lng?.toString(),
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
                        iconColor: buttonTextColor(context),
                        height: 42.h,
                        textStyle: AppTypography.buttonText14(context),
                        autoSize: false,

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
