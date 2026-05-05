import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/profile/data/models/profile_model.dart';
import 'package:bounce/bounce.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/api_path.dart';
import '../../../../core/constants/langCode.dart';
import 'all_member_ship/page/all_members_ship.dart';
import 'widget/info_member_ship.dart';

class MemberShipScrean extends StatefulWidget {
  const MemberShipScrean({Key? key, required this.member}) : super(key: key);
  final ProfileModel member;

  @override
  State<MemberShipScrean> createState() => _MemberShipScreanState();
}

class _MemberShipScreanState extends State<MemberShipScrean> {
  final Dio _dio = Dio();
  int? _availablePoints;
  String? _points;

  @override
  void initState() {
    super.initState();
    _fetchPointsData(widget.member.customerData!.idNumber ?? '0');
    _getMembershipColor(widget.member.membership!.name ?? "");

    print(" Membership name: ${widget.member.membership!.name ?? ""}");
  }

  // Fetch points data
  Future<void> _fetchPointsData(String idNumber) async {
    if (idNumber.isEmpty) return;

    try {
      final response = await _dio.get(
        '${oracleApi}/customerSync/$idNumber',
        options: _buildHeaders(),
      );

      final fetchedPoints = response.data['points'];
      setState(() {
        _points = fetchedPoints?.toString() ?? '0';
        _availablePoints = int.tryParse(_points!);
      });
    } catch (e) {
      print(e is DioError ? e.response?.data : "Unexpected Error: $e");
    }
  }

  Options _buildHeaders({String? token}) {
    return Options(
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Accept-Language": langCode.isEmpty ? 'en' : langCode,
        "Content-Type": "application/json",
      },
    );
  }

  Color _getMembershipColor(String membershipName) {
    switch (membershipName) {
      case "Gold":
      case "عضوية ذهبية":
        return Colors.white;
      case "Bronze":
      case "عضوية برونزية":
        return Colors.white;
      case "Platinum":
      case "عضوية بلاتنيوم":
        return Colors.white;
      case "Silver":
      case "عضوية فضية":
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale!.memberShip!.toString(),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 16,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10.h,
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
              height: 200.h,
              decoration: BoxDecoration(
                image: DecorationImage(
                  // fit: BoxFit.cover,
                  image: NetworkImage(widget.member.membership!.image!),
                ),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(widget.member.avatar! ?? ""),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 34.sp,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.member.name ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: _getMembershipColor(
                                widget.member.membership!.name ?? ""),
                            fontFamily: 'IBMPlexSansArabic',),
                      ),
                      Text(
                        widget.member.phone ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: _getMembershipColor(
                              widget.member.membership!.name ?? ""),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Text(
              locale.isDirectionRTL(context) == true
                  ? "رصيد نقاطك ${_availablePoints ?? 0} = ${(_availablePoints ?? 0) ~/ 10} ${locale.sar ?? 'SAR'}"
                  : "Points Balance ${_availablePoints ?? 0} = ${(_availablePoints ?? 0) ~/ 10} ${locale.sar ?? 'SAR'}",
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontSize: 14.sp),
            ),
            SizedBox(
              height: 15.sp,
            ),
            Stack(
              children: [
                Column(
                  children: [
                    InfoMemnerShip(
                      title: locale.rentalDiscount + " : ",
                      data: "${widget.member.membership!.rentalDiscount} %",
                      svgPic: 'assets/icons/rentalDiscount.svg',
                    ),
                    InfoMemnerShip(
                      title: locale.allowedKilos + " : ",
                      data: "${widget.member.membership!.allowedKilos} KM",
                      svgPic: 'assets/icons/allowedKilos.svg',
                    ),
                    InfoMemnerShip(
                      title: locale.extraHours + " : ",
                      data: widget.member.membership!.extraHours.toString(),
                      svgPic: 'assets/icons/extraHours.svg',
                    ),
                    InfoMemnerShip(
                      title: locale.regionsDiscount + " : ",
                      data:
                          "${widget.member.membership!.deliveryDiscountRegions} %",
                      svgPic: 'assets/icons/regionsDiscount.svg',
                    ),
                    InfoMemnerShip(
                      title: locale.ratioPoints,
                      data: "",
                      svgPic: 'assets/icons/ratioPoints.svg',
                    ),
                  ],
                )
              ],
            ),
            Padding(
              padding:   EdgeInsets.all(20.sp),
              child: Bounce(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => AllMemberShip(),
                    ),
                  );
                },
                child: Text.rich(
                  TextSpan(
                    text: locale.moreMembershipDetails,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: 14),
                    children: [
                      TextSpan(
                          text: locale.clickHere,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontSize: 14, color: Theme.of(context).colorScheme.onPrimary))
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
