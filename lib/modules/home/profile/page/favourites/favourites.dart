import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/cars/data/models/cars_model.dart';
import 'package:darbak/modules/widgets/components/error_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../widgets/components/appbar.dart';
import '../../../cars/presentaion/widget/car_tile.dart';
import '../../../search_screen/presentaion/widget/shimmer_list.dart';
import 'blocs/favourites_cubit/favourites_cubit.dart';

class Favourites extends StatefulWidget {
  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  late bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    var scaffoldKey = GlobalKey<ScaffoldState>();
    var locale = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => FavouritesCubit()..getFavourites(),
      child: BlocBuilder<FavouritesCubit, FavouritesState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: backgroundColor(context),
            key: scaffoldKey,
            appBar: CustomAppBar(
              title: locale.favourites!.toString(),
              showBackButton: true,
              // showThemeToggle: true,
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await BlocProvider.of<FavouritesCubit>(context).getFavourites();
              },
              child: state is FavouritesSuccess
                  ? state.favourites.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/emptystate.png", width: 220.w),
                    SizedBox(height: 6.h),
                    Text(
                      locale.addFavoriteCar,
                      style: AppTypography.mainTypographyColor20(context),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: state.favourites.length,
                itemBuilder: (context, index) {
                  final car = state.favourites[index];
                  final carMap = car.toMap();
                  carMap['total_price_before'] = car.toMap()['total_price_before'] ?? car.toMap()['price_before'];
                  carMap['total_price_after'] = car.toMap()['total_price_after'] ?? car.toMap()['price_after'];

                  return CarTile(
                    index: index,
                    datum: DataCars.fromMap(carMap),
                    isFavouritePage: true,
                    state: state,
                  );
                },
              )
                  : state is FavouritesLoading
                  ? ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => Padding(
                  padding:   EdgeInsets.symmetric(
                      vertical: 8.w, horizontal: 16.h),
                  child:ShimmerLoadingList(),
                ),
              )
                  : state is FavouritesFailed
                  ? ErrorImage(
                refresh: () {
                  BlocProvider.of<FavouritesCubit>(context)
                      .getFavourites();
                },
                error: state.error,
              )
                  : ErrorImage(
                refresh: () {
                  BlocProvider.of<FavouritesCubit>(context)
                      .getFavourites();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class VerticalDividerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14.h,
      width: 1,
      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
      margin: EdgeInsets.symmetric(horizontal: 6.w),
    );
  }
}