
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../cars/data/models/cars_model.dart';
import '../../datasources/favourites_services.dart';

part 'favourites_state.dart';

class FavouritesCubit extends Cubit<FavouritesState> {
  FavouritesCubit() : super(FavouritesInitial());

  getFavourites() async {
    emit(FavouritesLoading());
    try {
      final favourites = await FavouritesService.getFavourites();
      emit(FavouritesSuccess(favourites));
    } catch (error) {
      emit(FavouritesFailed(error.toString()));
    }
  }
}
