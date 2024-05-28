
import 'package:sharara_apps_building_helpers/sharara_apps_building_helpers.dart';
import 'package:sharara_laravel_sdk/src/Constants/boxes.dart';

class AuthProviderCache extends NormalCache {
  AuthProviderCache():super(
    boxName:LaravelBoxesConstants.authPCache,
  );
}