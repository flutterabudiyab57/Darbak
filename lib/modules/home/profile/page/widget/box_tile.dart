import 'dart:io';

import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/profile/data/models/profile_model.dart';
import 'package:darbak/modules/home/profile/page/widget/container_tile.dart';
import 'package:darbak/modules/home/profile/page/widget/space.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';


class BoxTileWidget extends StatefulWidget {
  const BoxTileWidget({Key? key, required this.profileModel}) : super(key: key);
  final ProfileModel profileModel;

  @override
  State<BoxTileWidget> createState() => _BoxTileWidgetState();
}

class _BoxTileWidgetState extends State<BoxTileWidget> {
  openWhatsApp() async {
    var whatsapp = "966557492493";
    Uri whatsappURlAndroid = Uri.parse(
        "whatsapp://send?phone=" + whatsapp + "&text=مرحبا بك في ابو دياب ");
    Uri whatappURLIos =
        Uri.parse("https://wa.me/$whatsapp?text=${Uri.parse("اطلب المساعده")}");

    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunchUrl(whatappURLIos)) {
        await launchUrl(
          whatappURLIos,
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("whatsapp no installed")));
      }
    } else {
      // android , web
      if (await canLaunchUrl(whatsappURlAndroid)) {
        await launchUrl(whatsappURlAndroid);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("whatsapp no installed")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    return Column(
      children: [
        ContainerTileWidget(widgets: [
          //SpaceWidget(),

          SpaceWidget(),
        ]),
        // SizedBox(
        //   height: MediaQuery.of(context).size.height * 0.01,
        // ),
      ],
    );
  }
}
