import 'package:darbak/modules/home/offers/service/offers_service.dart';
import 'package:darbak/modules/home/offers/widgets/offer_details_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../language/locale.dart';
import '../../widgets/components/appbar.dart';
import '../search_screen/presentaion/widget/shimmer_list.dart';
import 'model/offer_model.dart';

class OfferDetailsScreen extends StatefulWidget {
  final int offerId;

  const OfferDetailsScreen({Key? key, required this.offerId}) : super(key: key);

  @override
  _OfferDetailsScreenState createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends State<OfferDetailsScreen> {
  final OffersService _offerService = OffersService();
  OfferModel? offer;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOfferDetails();
  }

  Future<void> _loadOfferDetails() async {
    try {
      final offerData = await _offerService.fetchOfferDetails(widget.offerId);
      setState(() {
        offer = offerData;
        errorMessage = null;
      });
    } catch (error) {
      print("Failed to load offer details: $error");
      setState(() {
        errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
          title:locale.offerDetails,

          showBackButton: true,
          // showThemeToggle: true,
        ),
        body: errorMessage != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                "assets/anim/offer_discount_anim.json",
                width: 250.w,
              ),
              Text(
                locale.noOfferDetailsYet,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
            : offer == null
            ? Center(
          child: ShimmerLoadingList( itemCount: 7,
          ),
        )
            : Padding(
          padding:   EdgeInsets.all(8.sp),
          child: OfferDetailsContent(offer: offer!),
        ),
      ),
    );
  }
}
