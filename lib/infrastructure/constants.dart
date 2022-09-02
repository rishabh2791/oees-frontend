import 'package:flutter/material.dart';

// String baseURL = "http://172.21.100.42:8080/";
// String baseURL = "http://192.168.148.174:8000/";
String baseURL = "http://10.19.0.70/backend/";
const backgroundColor = Colors.black;
const foregroundColor = Colors.green;
const lightModeShadowColor = Colors.black;
const darkModeShadowColor = Colors.white;
const screenScaleRatio = 0.4;

const lightThemeFormLabelTextColor = Colors.green;
const darkThemeFormLabelTextColor = Colors.black;

DateTime minDate = DateTime.parse("1900-01-01");
DateTime maxDate = DateTime.parse("2099-12-31");
RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
