import 'package:darbak/modules/home/cars/data/models/cars_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../widgets/components/appbar.dart';

class ImageCarPage extends StatelessWidget {
  const ImageCarPage({Key? key, required this.photo}) : super(key: key);
  final List<Photo> photo;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:"",
        showBackButton: true,
        // showThemeToggle: true,
      ),
      body: PageView.builder(
        itemCount: photo.length,
        itemBuilder: (context, index) {
          return Container(
            height: 50.h,
            width: 50.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              image: DecorationImage(
                onError: (e, s) {
                  Center( child: LoadingIndicator()
                  );
                },
                image: NetworkImage(photo[index].url!),
              ),
            ),
          );
        },
      ),
    );
  }
}
