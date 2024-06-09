

import 'package:flutter/widgets.dart';
import 'package:sharara_apps_building_helpers/ui.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/src/Constants/boxes.dart';
import 'package:sharara_laravel_sdk/src/Constants/constants.dart';

class LaravelConfigurations extends LaravelSDKInitializer {
  WhatsAppAuthor? whatsAppAuthor;
  Widget? appLogo;
  String appName,mainApiUrl;
  final bool activateFBPhoneAuth;
  final Color mainColor;
  static  LaravelConfigurations? configurations ;
  LaravelConfigurations({
    this.whatsAppAuthor,
    this.appLogo,
    this.activateFBPhoneAuth = false,
    required this.appName,
    required this.mainApiUrl,
    this.mainColor = RoyalColors.lightBlue
  });
}


class LaravelSDKInitializer {

  static initialize(
      {final List<String> withBoxesNames = const [],
      final LaravelConfigurations Function()? configurations
      }
      )async{
    await ShararaAppHelperInitializer.initialize(
      initTheseBoxesNames:[
        ...LaravelBoxesConstants.boxes,
        ...withBoxesNames
      ],
      lazyBoxesNames:[
        ...Constants.boxes
      ]
    );
   if(configurations!=null)LaravelConfigurations.configurations = configurations();
  }

}