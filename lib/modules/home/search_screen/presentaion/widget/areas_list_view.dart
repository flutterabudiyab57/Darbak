import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/home/search_screen/data/models/areas_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AreasListView extends StatelessWidget {
  final List<AreasModel>? areas;
  final bool isReceive;

  const AreasListView({Key? key, required this.areas, required this.isReceive})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final locale = AppLocalizations.of(context);
    return ListView.builder(
        padding: EdgeInsets.only(bottom: kFloatingActionButtonMargin + 56),
        physics: BouncingScrollPhysics(),
        itemCount: areas!.length,
        itemExtent: 110.h,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              isReceive
                  ? BlocProvider.of<SearchCubit>(context).selectedReceiveArea =
                      areas![index].name
                  : BlocProvider.of<SearchCubit>(context).selectedDriveArea =
                      areas![index].name;

              BlocProvider.of<SearchCubit>(context).selectedAreaReceiveModel =
                  BlocProvider.of<SearchCubit>(context)
                      .areasData
                      ?.where((element) => element.name == areas![index].name)
                      .first;
              BlocProvider.of<SearchCubit>(context).changeState();
              Navigator.pop(context);
            },
            child: Container(
              height: size.height * 0.128,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: locale!.isDirectionRTL(context)
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      areas![index].name.toString(),
                      style: Theme.of(context).textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    AutoSizeText(areas![index].radius.toString(),
                        style: Theme.of(context).textTheme.bodyMedium),

                    SizedBox(height: 10.h),
                    // Divider(height: 2)
                  ],
                ),
              ),
            ),
          );
        });
  }
}
