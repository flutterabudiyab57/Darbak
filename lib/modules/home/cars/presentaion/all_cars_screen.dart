import 'package:auto_size_text/auto_size_text.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/cars/presentaion/page/filter_cars.dart';
import 'package:darbak/modules/home/cars/presentaion/search_cars/search_about_car.dart';
import 'package:darbak/modules/home/cars/presentaion/widget/build_empty_car.dart';
import 'package:darbak/modules/home/cars/presentaion/widget/filter_widget.dart';
import 'package:darbak/modules/home/search_screen/data/models/filter_model.dart';
import 'package:darbak/modules/widgets/components/error_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../core/constants/assets/app_colors.dart';
import '../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../core/style/style.dart';
import '../../../shell/app_shell.dart';
import '../../../shell/tab_scroll_registry.dart';
import '../../profile/blocs/profile_cubit/profile_cubit.dart';
import '../../profile/data/models/profile_model.dart';
import 'bloc/all_cars_cubit/all_cars_cubit.dart';
import 'bloc/cubit/cars_cubit.dart';
import 'widget/car_tile.dart';
import 'package:darbak/service_locator.dart';

class AllCarsScreen extends StatefulWidget {
  final FilterModel? filterModel;
  final bool fromFilter;
  final ProfileModel? model;

  const AllCarsScreen(
      {Key? key, this.filterModel, this.fromFilter = false, this.model})
      : super(key: key);

  static Widget entry({
    FilterModel? filterModel,
    bool fromFilter = false,
    ProfileModel? model,
  }) =>
      BlocProvider<AllCarsCubit>(
        create: (_) => sl<AllCarsCubit>(),
        child: AllCarsScreen(
          filterModel: filterModel,
          fromFilter: fromFilter,
          model: model,
        ),
      );

  @override
  State<AllCarsScreen> createState() => _AllCarsScreenState();
}

class _AllCarsScreenState extends State<AllCarsScreen>
    with TickerProviderStateMixin {
  late int pageNumber;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  TabScrollRegistry? _registry;

  late AnimationController filterPanelAnimationController;
  late Animation<double> filterPanelExpansionAnimation;
  late Animation<double> filterPanelInternalAnimation;

  @override
  @override
  void initState() {
    pageNumber = 1;

    filterPanelAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    filterPanelExpansionAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: filterPanelAnimationController,
        curve: Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );
    filterPanelInternalAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: filterPanelAnimationController,
        curve: Interval(0.5, 1, curve: Curves.easeIn),
      ),
    );

    super.initState();
  }
  @override
  void dispose() {
    _registry?.unregister(1, _scrollController);
    _scrollController.dispose();
    filterPanelAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final registry = shellScrollRegistryOf(context);
    if (registry != _registry) {
      _registry?.unregister(1, _scrollController);
      _registry = registry;
      _registry?.register(1, _scrollController);
    }
    if (widget.fromFilter) {
      pageNumber = 1;
      BlocProvider.of<AllCarsCubit>(context).getCarsByFilter(
        pageNumber,
      );
    } else {
      BlocProvider.of<AllCarsCubit>(context).getAllCars(
        pageNumber,
        branchId: widget.filterModel?.selectedBranch?.id,
      );
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: backgroundColor(context),
      appBar: AppBar(
        backgroundColor: backgroundColor(context),
        toolbarHeight: 80.hs(context),
        title: AutoSizeText(
          widget.filterModel?.selectedBranch?.name ?? locale.allCar.toString(),
          style: AppTypography.headingColor22(context),
        ),
        elevation: 0.0,
        actions: [
          widget.fromFilter
              ? SizedBox()
              : IconButton(
            onPressed: () {
              PersistentNavBarNavigator.pushNewScreen(context,
                  screen: FiltersCars.entry());
            },
            icon: Image.asset(
              "assets/icons/filter_new.png",
              width: 37.w,
              height: 34.h,
              color: iconDefaultColor(context),
            ),
          ),
        ],
      ),
      key: _scaffoldKey,
      body: RefreshIndicator(
        onRefresh: () async {
          if (widget.fromFilter) {
            await BlocProvider.of<AllCarsCubit>(context).getCarsByFilter(1);
          } else {
            await BlocProvider.of<AllCarsCubit>(context).getAllCars(1);
          }
        },
        child: Stack(
          children: [
            BlocConsumer<AllCarsCubit, AllCarsState>(
                listener: (context, state) {
                  if (state is AllCarsLodError) {
                    print("AllCarsLodError: ${state.error}");
                  }
                },
                builder: (context, state) {
                  if (state is CarsInitial) {
                    getMoreCars(
                        context,
                        BlocProvider.of<ProfileCubit>(context).custClass.toString(),
                        pageNumber);
                    return Center(
                        child: LoadingIndicator()

                    );
                  } else {
                    var cubit = AllCarsCubit.get(context).cars;
                    return AllCarsCubit.get(context).cars == null
                        ? state is CarsLodError
                        ? ErrorImage(
                      refresh: () {
                        BlocProvider.of<AllCarsCubit>(context).getAllCars(
                          pageNumber,
                          branchId:
                          widget.filterModel?.selectedBranch?.id,
                        );
                        print("Error Image :::::::::::::::::");
                      },
                    ) : Center(
                      child: SizedBox(
                        width: 1.sw * 0.8,
                        child: LoadingIndicator(),
                      ),
                    )
                        : BlocProvider.of<AllCarsCubit>(context).cars!.data!.isEmpty
                        ? Center(
                      child: SizedBox(
                        width: 1.sw * 0.8,
                        child: BuildEmptyCar(  title: locale.noCarsCurrently,),
                      ),
                    )
                        : Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation,
                                    secondaryAnimation) {
                                  return SearchCarScreen();
                                },
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                      opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              SizedBox(height: 8.h),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 8.w),
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                height: 50.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.r),
                                  border: Border.all(
                                    color: strokeGrayColor(context),
                                    width: 2.w,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      locale.isDirectionRTL(context)
                                          ? "ابحث عن سيارتك المفضلة..."
                                          : 'Search on your favorite car...',
                                      style: AppTypography.paragraphColor16(context),
                                    ),
                                    Icon(
                                      Icons.search,
                                      size: 25.sp,
                                      color: iconDefaultColor(context),

                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Expanded(
                          child: ListView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: cubit!.data!.length,
                              itemBuilder: (context, index) {
                                  return CarTile(
                                    cubit: cubit,
                                    index: index,
                                    filterModel: widget.filterModel,
                                    state: state,
                                  );
                              }),
                        ),
                        SizedBox(height: 1.sh * 0.02),
                      ],
                    );
                  }
                }),
            if (!widget.fromFilter)
              AnimatedBuilder(
                animation: filterPanelExpansionAnimation,
                builder: (context, child) {
                  final value = filterPanelExpansionAnimation.value;
                  return Opacity(
                      opacity: value,
                      child: Visibility(
                        visible: value > 0,
                        child: child!,
                      ));
                },
                child: FilterWidget(),
              ),
          ],
        ),
      ),
    );
  }

  getMoreCars(BuildContext context, cast_class, int page_num) {
    if (widget.fromFilter) {
      BlocProvider.of<AllCarsCubit>(context).getCarsByFilter(
        pageNumber,
      );
    }
    BlocProvider.of<AllCarsCubit>(context).getAllCars(
      page_num,
      branchId: widget.filterModel?.selectedBranch?.id,
    );
  }
}