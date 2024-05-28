

import 'package:sharara_apps_building_helpers/ui.dart';
import 'package:sharara_laravel_sdk/src/Constants/boxes.dart';
import 'package:sharara_laravel_sdk/src/Constants/constants.dart';

class LaravelSDKInitializer {

  static initialize(
      {final List<String> withBoxesNames = const []}
      )async{
    await ShararaAppHelperInitializer.initialize(
      initTheseBoxesNames:[
        ... LaravelBoxesConstants.boxes,
        ...withBoxesNames
      ],
      lazyBoxesNames:[
        ...Constants.boxes
      ]
    );
  }
}