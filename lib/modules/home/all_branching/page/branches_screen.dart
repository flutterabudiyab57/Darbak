import 'package:auto_size_text/auto_size_text.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/all_branching/bloc/all_branching_cubit.dart';
import 'package:darbak/modules/home/all_branching/bloc/all_branching_state.dart';
import 'package:darbak/modules/home/all_branching/page/view_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                        fillColor: bg2Color(context),
                        borderColor: Colors.transparent,
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

        final int? period = branch.workTime?.alldays?.period;
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
                      branch.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.mainTypographyColor15(context),
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                  if ((branch.region ?? '').isNotEmpty) ...[
                    SizedBox(width: 3.w,),
                    AutoSizeText(
                      "( ${branch.region!} )",
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
                                if (branch.workTime?.openAllDays == 1)
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
                                          text: "${branch.workTime?.alldays?.morning?.timeopen ?? ''} - ${branch.workTime?.alldays?.morning?.timeclose ?? ''}",
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
                                            text: "${branch.workTime?.alldays?.afternone?.timeopen ?? ''} ${locale.toTime} ${branch.workTime?.alldays?.afternone?.timeclose ?? ''}",
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
