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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is OffersLoded) {
          _cachedOffers = state.offers;
        }

        if (state is OffersLoding && _cachedOffers == null) {
          return Center(child: LoadingIndicator());
        }

        if (_cachedOffers != null && _cachedOffers!.isNotEmpty) {
          return _buildOffersCarousel(context, _cachedOffers!);
        }

        return _buildEmptyOffersFallback(context);
      },
    );
  }

  Widget _buildOffersCarousel(BuildContext context, List<OffersModel> offers) {
    final locale = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, locale),
        SizedBox(height: 10.h),
        SizedBox(
          height: 150.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: offers.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final offer = offers[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: Image.network(
                    offer.image ?? '',
                    width: double.infinity,
                    height: 150.h,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Center(
                        child: Icon(Icons.image_not_supported, size: 40.sp),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10.h),
        _buildBottomRow(context, offers.length, locale),
      ],
    );
  }

  Widget _buildEmptyOffersFallback(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, locale),
        SizedBox(height: 10.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(15.r),
          child: Image.asset(
            'assets/images/3Cars.png',
            height: 150.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 10.h),
        _buildBottomRow(context, 1, locale),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations locale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AutoSizeText(
          locale.discoverOffers,
          style: AppTypography.headingColor16(context),
        ),
        SizedBox(width: 5.w),
        SizedBox(
          width: 18.w,
          height: 18.h,
          child: SvgPicture.asset(
            Assets.icon_offers,
            color: strokeMainColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomRow(
      BuildContext context, int dotsCount, AppLocalizations locale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: widget.onViewAllTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: strokeMainColor(context),
                width: 1.5.w,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back,
                  color: iconDefaultColor(context),
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  locale.viewAll.toString(),
                  style: AppTypography.headingColor12(context),
                ),
              ],
            ),
          ),
        ),
        if (dotsCount > 1)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(dotsCount, (index) {
              final isActive = index == _currentPage;
              return Padding(
                padding: EdgeInsets.only(left: index > 0 ? 5.w : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isActive ? 32.w : 11.w,
                  height: 11.h,
                  decoration: ShapeDecoration(
                    color: isActive
                        ? iconDefaultColor(context)
                        : iconGrayColor(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        isActive ? 17.r : 100.r,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }
}
