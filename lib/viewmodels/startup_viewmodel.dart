import 'dart:async';

import 'package:appetizer/locator.dart';
import 'package:appetizer/services/local_storage_service.dart';
import 'package:appetizer/services/push_notification_service.dart';
import 'package:appetizer/services/remote_config_service.dart';
import 'package:appetizer/ui/home_view.dart';
import 'package:appetizer/ui/login/login_view.dart';
import 'package:appetizer/ui/on_boarding/on_boarding_view.dart';
import 'package:appetizer/viewmodels/base_model.dart';
import 'package:get/get.dart';

class StartUpViewModel extends BaseModel {
  final PushNotificationService _pushNotificationService =
      locator<PushNotificationService>();
  final RemoteConfigService _remoteConfigService =
      locator<RemoteConfigService>();
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();

  Future handleStartUpLogic() async {
    await _pushNotificationService.initialise();
    await _remoteConfigService.initialise();

    if (_localStorageService.isFirstTimeLogin) {
      _localStorageService.isFirstTimeLogin = false;
      await Get.offAllNamed(OnBoardingView.id);
    } else if (_localStorageService.isLoggedIn) {
      await Get.offAllNamed(HomeView.id);
    } else {
      await Get.offAllNamed(LoginView.id);
    }
  }
}
