import 'dart:math' as math;

import 'package:appetizer/change_notifiers/menu_model.dart';
import 'package:appetizer/colors.dart';
import 'package:appetizer/models/menu/week.dart';
import 'package:appetizer/services/menu.dart';
import 'package:appetizer/services/multimessing/switch_meals.dart';
import 'package:appetizer/ui/components/alert_dialog.dart';
import 'package:appetizer/ui/components/inherited_data.dart';
import 'package:appetizer/ui/components/progress_bar.dart';
import 'package:appetizer/ui/components/switch_confirmation_meal_card.dart';
import 'package:appetizer/ui/menu/meals_menu_cards.dart';
import 'package:appetizer/ui/multimessing/confirmed_switch_screen.dart';
import 'package:appetizer/utils/date_time_utils.dart';
import 'package:appetizer/utils/get_hostel_code.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ConfirmSwitchPopupScreen extends StatefulWidget {
  final Meal meal;

  const ConfirmSwitchPopupScreen({
    Key key,
    this.meal,
  }) : super(key: key);

  @override
  _ConfirmSwitchPopupScreenState createState() =>
      _ConfirmSwitchPopupScreenState();
}

class _ConfirmSwitchPopupScreenState extends State<ConfirmSwitchPopupScreen> {
  static final double _radius = 16;
  int currentHostelMealId;
  InheritedData inheritedData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (inheritedData == null) {
      inheritedData = InheritedData.of(context);
    }
  }

  List<CircleAvatar> mealFromWhichToBeSwitchedLeadingImageList = [];
  List<String> mealFromWhichToBeSwitchedItemsList = [];
  Map<CircleAvatar, String> mealFromWhichToBeSwitchedMap = {};

  void setLeadingMealImage(List<CircleAvatar> mealLeadingImageList) {
    mealLeadingImageList.add(CircleAvatar(
      radius: _radius,
      backgroundColor: Colors.transparent,
      child: Image.asset(
        "assets/icons/meal_icon" +
            (math.Random().nextInt(5) + 1).toString() +
            ".jpg",
        scale: 2.5,
      ),
    ));
  }

  void setMealFromWhichToBeSwitchedComponents(Meal mealFromWhichToBeSwitched) {
    mealFromWhichToBeSwitchedItemsList = [];
    mealFromWhichToBeSwitchedLeadingImageList = [];
    for (var j = 0; j < mealFromWhichToBeSwitched.items.length; j++) {
      var mealItem = mealFromWhichToBeSwitched.items[j].name;
      mealFromWhichToBeSwitchedItemsList.add(mealItem);
      setLeadingMealImage(mealFromWhichToBeSwitchedLeadingImageList);
    }
  }

  Map<String, MealType> titleToMealTypeMap = {
    "Breakfast": MealType.B,
    "Lunch": MealType.L,
    "Snacks": MealType.S,
    "Dinner": MealType.D,
  };

  TextStyle getSwitchToOrFromStyle() {
    return TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Confirm Meal Switch",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: Container(),
        backgroundColor: appiBrown,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: menuWeekMultiMessing(
          inheritedData.userDetails.token,
          DateTimeUtils.getWeekNumber(widget.meal.startDateTime),
          hostelCodeMap[inheritedData.userDetails.hostelName],
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ProgressBar();
          } else {
            snapshot.data.days.forEach((dayMenu) {
              String mealDateString = dayMenu.date.toString().substring(0, 10);
              dayMenu.meals.forEach((mealMenu) {
                if (mealDateString ==
                        widget.meal.startDateTime.toString().substring(0, 10) &&
                    titleToMealTypeMap[widget.meal.title] == mealMenu.type) {
                  currentHostelMealId = mealMenu.id;
                  setMealFromWhichToBeSwitchedComponents(mealMenu);
                  mealFromWhichToBeSwitchedMap = Map.fromIterables(
                    mealFromWhichToBeSwitchedLeadingImageList,
                    mealFromWhichToBeSwitchedItemsList,
                  );
                }
              });
            });

            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Switch From",
                          style: getSwitchToOrFromStyle(),
                        ),
                      ),
                      SwitchConfirmationMealCard(
                        token: inheritedData.userDetails.token,
                        id: widget.meal.id,
                        title: widget.meal.title,
                        menuItems: mealFromWhichToBeSwitchedMap,
                        mealStartDateTime: widget.meal.startDateTime,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Image.asset(
                            "assets/icons/switch_active.png",
                            scale: 1.5,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Switch To",
                          style: getSwitchToOrFromStyle(),
                        ),
                      ),
                      SwitchConfirmationMealCard(
                        token: inheritedData.userDetails.token,
                        id: widget.meal.id,
                        title: widget.meal.title,
                        menuItems: MenuCardUtils.getMapMenuItems(widget.meal),
                        mealStartDateTime: widget.meal.startDateTime,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          FlatButton(
                            child: Text(
                              "CANCEL",
                              style: TextStyle(
                                color: appiYellow,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text(
                              "SWITCH",
                              style: TextStyle(
                                color: appiYellow,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () {
                              showCustomDialog(context, "Switching Meals");
                              switchMeals(
                                currentHostelMealId,
                                hostelCodeMap[widget.meal.hostelName],
                                inheritedData.userDetails.token,
                              ).then((switchResponse) {
                                Provider.of<OtherMenuModel>(context,
                                        listen: false)
                                    .getOtherMenu(DateTimeUtils.getWeekNumber(
                                        widget.meal.startDateTime));
                                Provider.of<YourMenuModel>(context,
                                        listen: false)
                                    .selectedWeekMenuYourMeals(
                                        DateTimeUtils.getWeekNumber(
                                            widget.meal.startDateTime));
                                if (switchResponse == true) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ConfirmedSwitchScreen(),
                                    ),
                                  );
                                } else {
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                      msg: "Cannot switch meals");
                                }
                              });
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
