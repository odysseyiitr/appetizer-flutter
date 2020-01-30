import 'package:appetizer/models/menu/week.dart';
import 'package:appetizer/models/user/user_details_shared_pref.dart';
import 'package:appetizer/services/menu.dart';
import 'package:appetizer/utils/get_hostel_code.dart';
import 'package:appetizer/utils/get_week_id.dart';
import 'package:appetizer/utils/user_details.dart';
import 'package:flutter/foundation.dart';

// FIXME: Solve the bug, menu does-not load on first time login

class MenuModel extends ChangeNotifier {
  Week _currentWeek;

  MenuModel(UserDetailsSharedPref userDetails) {
//    currentWeekMenu();
    currentWeekMenuMultiMessing(userDetails);
  }

  Week get data => _currentWeek;

  // FIXME: Probably Changes made in backend side type mismatch error
  void currentWeekMenu() {
    // TODO: store user details in a separate model (user details should be fetched only once during the start of the app
    UserDetailsUtils.getUserDetails().then((details) async {
      _currentWeek = await menuWeek(
          details.getString("token"), getWeekNumber(DateTime.now()));
      notifyListeners();
    });
  }

  void currentWeekMenuMultiMessing(UserDetailsSharedPref userDetails) async {
    _currentWeek = await menuWeekMultiMessing(
        userDetails.token, getWeekNumber(DateTime.now()), hostelCodeMap[userDetails.hostelName]);
    notifyListeners();
  }
}
