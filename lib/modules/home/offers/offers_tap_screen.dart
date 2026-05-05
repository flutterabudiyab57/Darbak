
import 'package:darbak/core/style/style.dart';
import 'package:darbak/modules/home/offers/service/offers_service.dart';
import 'package:darbak/modules/home/offers/widgets/offer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/assets/app_colors.dart';
import '../../../core/constants/assets/assets.dart';
import '../../../language/locale.dart';
import '../../widgets/components/appbar.dart';
import '../search_screen/presentaion/widget/shimmer_list.dart';

class OffersScreen extends StatefulWidget {

  final bool fromNotification;

  OffersScreen({this.fromNotification = false});

  @override
  _OffersScreenState createState() => _OffersScreenState();
}
class _OffersScreenState extends State<OffersScreen> {
  final OffersService _offersService = OffersService();
  List<dynamic> offers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }



  Future<void> fetchOffers() async {
    final data = await _offersService.fetchOffers();
    if (mounted) {
      setState(() {
        offers = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async {
        if (widget.fromNotification) {
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context);
          } else {
            return false;
          }
        }
        return true;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: backgroundColor(context),
          appBar: CustomAppBar(
            title: locale.isDirectionRTL(context) ? "عروضنا" : "Our offers,",
            showBackButton: true,
            // showThemeToggle: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 28.w,
                      height: 28.h,
                      child: SvgPicture.asset(Assets.icon_offers,color: strokeMainColor(context),),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      locale.isDirectionRTL(context)
                          ? "إستكشف العروض الحصرية "
                          : "Explore exclusive offers",
                      style: AppTypography.headingColor20(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(
                  child: ShimmerLoadingList(height: 160,
                  ),
                )
                    : offers.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        "assets/anim/offer_discount_anim.json",
                        width: 250.w,
                      ),
                      Text(
                        locale.isDirectionRTL(context)
                            ? "ترقبوا اقوى العروض."
                            : "Stay tuned for the best offers soon.",
                        style: AppTypography.mainTypographyColor24(context),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    return OfferCard(
                      id: offer['id'],
                      name: offer['name'],
                      from: offer['from'],
                      to: offer['to'],
                      description: offer['description'],
                      coupon: offer['coupon'],
                      discountValue: offer['discount_value'],
                      imageUrl: offer['image'],
                      coupon_is_work: offer['coupon_is_work'],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}
