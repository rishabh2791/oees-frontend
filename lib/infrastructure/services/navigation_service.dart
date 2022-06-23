import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

NavigationService navigationService = NavigationService();

class NavigationService {
  GlobalKey<NavigatorState>? navigatorKey;
  static final NavigationService _navigationService = NavigationService._internal();

  factory NavigationService() {
    return _navigationService;
  }

  NavigationService._internal() {
    navigatorKey = GlobalKey<NavigatorState>();
  }

  Future<Object?>? pushReplacement(Route<Object> route) {
    return navigatorKey?.currentState?.pushReplacement(route);
  }

  Future<Object?>? push(Route<Object> route) {
    return navigatorKey?.currentState?.push(route);
  }

  Future<Object?>? pushAndRemoveUntil(Route<Object> route) {
    return navigatorKey?.currentState?.pushAndRemoveUntil(route, (route) => false);
  }
}
