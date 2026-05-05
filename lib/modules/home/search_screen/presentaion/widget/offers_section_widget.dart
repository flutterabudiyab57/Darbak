import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/core/constants/assets/assets.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_state.dart';
import 'package:darbak/modules/home/search_screen/data/models/offers_model.dart';

import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../../language/locale.dart';

class OffersSectionWidget extends StatefulWidget {
  final VoidCallback onViewAllTap;

  const OffersSectionWidget({
    Key? key,
    required this.onViewAllTap,
  }) : super(key: key);

  @override
  State<OffersSectionWidget> createState() => _OffersSectionWidgetState();
}

class _OffersSectionWidgetState extends State<OffersSectionWidget> {
  List<OffersModel>? _cachedOffers;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is OffersLoded) {
          _cachedOffers = state.offers;
        }

        if (state is OffersLoding && _cachedOffers == null) {
          return _buildContainer(
            context,
            child: Center(
              child: LoadingIndicator(),
            ),
          );
        }

        if (_cachedOffers != null && _cachedOffers!.isNotEmpty) {
          return _buildOfferCard(context, _cachedOffers!.first);
        }

        return _buildEmptyOffersFallback(context);
      },
    );
  }

  Widget _buildContainer(BuildContext context, {required Widget child}) {
    return Container(
       decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: strokeGrayColor(context), width: 1.5.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: child,
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, OffersModel offer) {
    return _buildContainer(
      context,
      child: Column(
        children: [
          _buildHeader(context),
          SizedBox(height: 8.h),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: Image.network(
                  offer.image ?? '',
                  height: 100.h,
                  width: 168.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100.h,
                    width: 168.w,
                    color: Colors.grey[300],
                    child: Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      Directionality.of(context) == TextDirection.rtl
                          ? "احصل على خصم ${offer.discountValue ?? 0}% عند الدفع بالفيزا"
                          : "Get a ${offer.discountValue ?? 0}% discount when paying with Visa",
                      style: AppTypography.headingColor10(context),
                    ),
                    SizedBox(height: 5.h),
                    AutoSizeText(
                      offer.description ?? '',
                      style: AppTypography.paragraphColor12(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildViewAllButton(context),
        ],
      ),
    );
  }

  Widget _buildEmptyOffersFallback(BuildContext context) {

    return _buildContainer(
      context,
      child: Column(
        children: [
          _buildHeader(context),
          SizedBox(height: 8.h),
          Row(
            children: [
              Image.asset(
                'assets/images/3Cars.png',
                height: 100.h,
                width: 158.w,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      Directionality.of(context) == TextDirection.rtl
                          ? "نجهّز لك حاليًا عروض وباقات مميزة"
                          : "We are currently preparing special offers and packages for you",
                      style: AppTypography.headingColor10(context),
                    ),
                    SizedBox(height: 5.h),
                    AutoSizeText(
                      Directionality.of(context) == TextDirection.rtl
                          ? "تابعنا عشان تكون أول المستفيدين"
                          : "Follow us to be among the first to benefit",
                      style: AppTypography.paragraphColor12(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildViewAllButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 21.w,
          height: 21.h,
          child: SvgPicture.asset(Assets.icon_offers,color: strokeMainColor(context),),
        ),
        SizedBox(width: 5.w),
        AutoSizeText(
          Directionality.of(context) == TextDirection.rtl
              ? "اسكتشف العروض الحصرية"
              : "Discover exclusive offers",
          style: AppTypography.headingColor16(context),
        ),
      ],
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: strokeMainColor(context),
            thickness: 2.h,
          ),
        ),
        SizedBox(width: 6.w),
        GestureDetector(
          onTap: widget.onViewAllTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: strokeMainColor(context),
                width: 1.5.w,
              ),
            ),
            child: Row(
              children: [
                AutoSizeText(
                 locale.viewAll.toString(),
                  style: AppTypography.headingColor12(context),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: iconDefaultColor(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}