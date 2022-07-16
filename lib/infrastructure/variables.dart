import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oees/domain/entity/user.dart';
import 'package:oees/interface/device/device_widget.dart';
import 'package:oees/interface/device_data/device_data_widget.dart';
import 'package:oees/interface/downtime/downtime_widget.dart';
import 'package:oees/interface/downtime_preset/downtime_preset_widget.dart';
import 'package:oees/interface/home/home_widget.dart';
import 'package:oees/interface/job/job_widget.dart';
import 'package:oees/interface/line/line_widget.dart';
import 'package:oees/interface/shift/shift_widget.dart';
import 'package:oees/interface/sku/sku_widget.dart';
import 'package:oees/interface/sku_speed/sku_speed_widget.dart';
import 'package:oees/interface/task/task_widget.dart';
import 'package:oees/interface/user/user_widget.dart';
import 'package:oees/interface/user_role/user_role_widget.dart';
import 'package:oees/interface/user_role_access/user_role_access_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isMenuCollapsed = true;
ValueNotifier<bool> isDarkTheme = ValueNotifier<bool>(true);
bool isLoggedIn = false;
bool isError = false;
String errorMessage = "";

late User currentUser;

bool isRefreshing = false;
bool isLoadingServerData = false;
SharedPreferences? storage;
String menuItemSelected = "Home";
String companyID = "";
String factoryID = "";
late DateTime accessTokenExpiryTime;
String webSocketURL = "ws://localhost/";

late NumberFormat numberFormat;

Map<String, Map<String, dynamic>> menuMapping = {
  "Home": {
    "table": "",
    "widget": const HomeWidget(),
  },
  "Devices": {
    "table": "devices",
    "widget": const DeviceWidget(),
  },
  "Device Data": {
    "table": "device_data",
    "widget": const DeviceDataWidget(),
  },
  "Downtime": {
    "table": "downtimes",
    "widget": const DowntimeWidget(),
  },
  "Job": {
    "table": "jobs",
    "widget": const JobWidget(),
  },
  "Line": {
    "table": "lines",
    "widget": const LineWidget(),
  },
  "Preset Downtimes": {
    "table": "preset_downtimes",
    "widget": const DowntimePresetWidget(),
  },
  "Shift": {
    "table": "shifts",
    "widget": const ShiftWidget(),
  },
  "SKU": {
    "table": "skus",
    "widget": const SKUWidget(),
  },
  "SKU Speed": {
    "table": "sku_speeds",
    "widget": const SKUSpeedWidget(),
  },
  "Task": {
    "table": "tasks",
    "widget": const TaskWidget(),
  },
  "User": {
    "table": "users",
    "widget": const UserWidget(),
  },
  "User Role": {
    "table": "user_roles",
    "widget": const UserRoleWidget(),
  },
  "User Access": {
    "table": "user_role_accesses",
    "widget": const UserRoleAccessWidget(),
  },
};
