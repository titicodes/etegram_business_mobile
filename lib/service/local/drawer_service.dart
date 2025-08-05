import 'package:flutter/material.dart';
import 'package:etegram_business/locator.dart';

class DrawerService {
  GlobalKey<ScaffoldState>? _scaffoldKey;

  void setScaffoldKey(GlobalKey<ScaffoldState> key) {
    _scaffoldKey = key;
    print('DrawerService: Scaffold key set');
  }

  void openDrawer() {
    if (_scaffoldKey?.currentState != null) {
      _scaffoldKey!.currentState!.openDrawer();
      print('DrawerService: Drawer opened');
    } else {
      print('DrawerService: Scaffold key or state is null');
    }
  }

  void closeDrawer() {
    if (_scaffoldKey?.currentState != null) {
      _scaffoldKey!.currentState!.closeDrawer();
      print('DrawerService: Drawer closed');
    } else {
      print('DrawerService: Scaffold key or state is null');
    }
  }
}