import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String baseURL = "us-central1-dvt-henri-potier.cloudfunctions.net";

DateFormat datetimeFormat = DateFormat("dd/MM/yyyy HH:mm");
DateFormat dateFormat = DateFormat("dd/MM/yyyy");

String capitalize(String msg) {
  return '${msg[0].toUpperCase()}${msg.substring(1)}';
}

class Palette {
  static const Color iconColor = Color(0xffaabbcc);
  static const Color primaryColor = Color(0xffffb01f);
  static const Color secondaryColor = Color(0xff679de5);
  static const Color thirdColor = Color(0xff679de5);
  static const Color fourthColor = Color(0xff8fb9f1);

  static const Color backgroundColor = Color(0xffecebe7);
  static const Color cardColor = Color(0xff000029);
}
