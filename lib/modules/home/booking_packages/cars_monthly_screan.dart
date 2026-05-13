import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/cars/presentaion/widget/filter_widget.dart';
import 'package:darbak/modules/home/search_screen/data/models/filter_model.dart';
import 'package:darbak/modules/widgets/components/error_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import '../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../core/style/style.dart';
import '../../widgets/components/appbar.dart';
import '../cars/presentaion/widget/car_tile.dart';
import '../profile/blocs/profile_cubit/profile_cubit.dart';
import '../cars/presentaion/bloc/cubit/cars_cubit.dart';
import 'package:darbak/service_locator.dart';

class CarsMonthlyScreen extends StatefulWidget {
  final FilterModel? filterModel;
  final bool fromFilter;

  const CarsMonthlyScreen({Key? key, this.filterModel, this.fromFilter = false})
      : super(key: key);

  static Widget entry({FilterModel? filterModel, bool fromFilter = false}) =>
      BlocProvider<CarsCubit>(
        create: (_) => sl<CarsCubit>(),
        child: CarsMonthlyScreen(filterModel: filterModel, fromFilter: fromFilter),
      );

  @override
  State<CarsMonthlyScreen> createState() => _CarsMonthlyScreenState();
}

class _CarsMonthlyScreenState extends State<CarsMonthlyScreen>
    with TickerProviderStateMixin {
  late int pageNumber;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = ScrollController();

  //animation
  late AnimationController filterPanelAnimationController;
  late Animation<double> filterPanelExpansionAnimation;
  late Animation<double> filterPanelInternalAnimation;

  @override
  void initState() {
    pageNumber = 1;

    dynamic customClass = BlocProvider.of<ProfileCubit>(context).custClass;
    BlocProvider.of<ProfileCubit>(context).getProfile();
     _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        pageNumber += 1;
        getMoreCars(context, customClass);
      }
    });
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
    filterPanelAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final locale = AppLocalizations.of(context)!;
    final carsCubit = BlocProvider.of<CarsCubit>(context);
    if (widget.fromFilter) {
      pageNumber = 1;
      carsCubit.getCarsByFilter(
        pageNumber,
        //available: carsCubit.filterCubit.available,
      );
    } else {
      BlocProvider.of<CarsCubit>(context).getAllCars(
        pageNumber,
        branchId: widget.filterModel?.selectedBranch?.id,
        languageCode: locale.locale.languageCode,
        castClass: BlocProvider.of<ProfileCubit>(context).custClass.toString(),
      );
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      appBar: CustomAppBar(
        title:widget.filterModel?.selectedBranch?.name ?? locale.allCar.toString(),
        showBackButton: true,
        // showThemeToggle: true,
      ),
      key: _scaffoldKey,
      body: RefreshIndicator(
        onRefresh: () async {
          if (widget.fromFilter) {
            BlocProvider.of<CarsCubit>(context).getAllCars(1);
          }
        },
        child: Stack(
          children: [
            SafeArea(
              child: BlocConsumer<CarsCubit, CarsState>(
                  listener: (context, state) {
                if (state is CarsLodError) {
                  Fluttertoast.showToast(
                    msg: locale.errorOccurredProcessing,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Color(0xffF6A9A9),
                    textColor: Colors.red,
                    fontSize: 14.sp,
                  );

                  print("carS sCREEN: ${state.error}");
                }
              }, builder: (context, state) {
                if (state is CarsInitial) {
                  getMoreCars(
                    context,
                    int.parse(BlocProvider.of<ProfileCubit>(context)
                            .custClass
                            .toString())
                        .toInt(),
                  );
                  return Center(
                      child: LoadingIndicator()
                  );
                } else {
                  var cubit = CarsCubit.get(context).cars;
                  return CarsCubit.get(context).cars == null
                      ? state is CarsLodError
                          ? ErrorImage(
                              refresh: () {
                                BlocProvider.of<CarsCubit>(context).getAllCars(
                                  pageNumber,
                                  branchId:
                                      widget.filterModel?.selectedBranch?.id,
                                  languageCode: locale.locale.languageCode,
                                  castClass:
                                      BlocProvider.of<ProfileCubit>(context)
                                          .custClass
                                          .toString(),
                                );
                              },
                            )
                          : Container()
                      : BlocProvider.of<CarsCubit>(context).cars!.data!.isEmpty
                          ? Center(
                              child: SizedBox(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Lottie.asset(
                                        "assets/anim/empty.json",
                                      ),
                                      Text(
                                        locale.noCarsInBranch.toString(),
                                        style: AppTypography.mainTypographyColor20(context),
                                      ),
                                    ],
                                  )),
                            )
                          : Column(
                              children: [
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
                                )
                              ],
                            );
                }
              }),
            ),
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

  TickerFuture driveFilterPanelAnimation() =>
      filterPanelAnimationController.isCompleted
          ? filterPanelAnimationController.reverse()
          : filterPanelAnimationController.forward();

  getMoreCars(BuildContext context, castClass) {
    if (widget.fromFilter) {
      BlocProvider.of<CarsCubit>(context).getCarsByFilter(pageNumber);
    }
    BlocProvider.of<CarsCubit>(context).getAllCars(pageNumber,
        branchId: widget.filterModel?.selectedBranch?.id,
        castClass: castClass.toString());
  }
}
