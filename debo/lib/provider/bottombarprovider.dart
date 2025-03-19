import 'package:flutter/material.dart';

class BottombarProvider extends ChangeNotifier {
  int bottomNavIndex = 0;
  bool isShowAppbar = true;

  setAppbarVisibility(bool isShowAppbar) {
    this.isShowAppbar = isShowAppbar;
    notifyListeners();
  }

  Future setBottomNavIndex(index) async {
    bottomNavIndex = index;
    notifyListeners();
  }

  clearProvider() {
    isShowAppbar = true;
    bottomNavIndex = 0;
  }
}
