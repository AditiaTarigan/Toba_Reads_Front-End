import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void navigateTo(String routeName, {Object? arguments}) {
  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    routeName,
        (Route<dynamic> route) => false,
    arguments: arguments,
  );
}