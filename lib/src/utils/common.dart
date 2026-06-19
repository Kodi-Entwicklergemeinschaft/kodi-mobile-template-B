import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:your_app_name/src/data/model/model_device.dart';
import 'package:http_parser/http_parser.dart';
import 'package:location/location.dart';
import 'package:your_app_name/src/utils/translate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static fieldFocusChange(
    BuildContext context,
    FocusNode current,
    FocusNode next,
  ) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  static String getStatus(int? statusId) {
    if (statusId != null) {
      switch (statusId) {
        case 1:
          return "approved";
        case 2:
          return "pending";
        case 3:
          return "feedback";
      }
    }
    return "";
  }

  static Color getStatusColor(int? statusId) {
    if (statusId != null) {
      switch (statusId) {
        case 1:
          return Colors.green;
        case 2:
          return Colors.orange;
        case 3:
          return Colors.red;
      }
    }
    return Colors.grey;
  }




  static hiddenKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static Future<DeviceModel?> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final android = await deviceInfoPlugin.androidInfo;
        return DeviceModel(
          uuid: android.id,
          model: "Android",
          version: android.version.sdkInt.toString(),
          type: android.model,
        );
      } else if (Platform.isIOS) {
        final IosDeviceInfo ios = await deviceInfoPlugin.iosInfo;
        if (ios.identifierForVendor != null) {
          return DeviceModel(
            uuid: ios.identifierForVendor!,
            name: ios.name,
            model: ios.systemName,
            version: ios.systemVersion,
            type: ios.utsname.machine,
          );
        } else {
          throw ("no uuid");
        }
      }
    } catch (e) {
      // UtilLogger.log("ERROR", e);
    }
    return null;
  }

  static Future<LocationData?> getLocation() async {
    Location location = Location();
    PermissionStatus permissionGranted;
    LocationData? locationData;

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return locationData;
      }
    }

    return await location.getLocation();
  }

  void copyToClipboard(BuildContext context, String message) {
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(Translate.of(context).translate('copied_to_clipboard'))),
    );
  }


  Future<void> launchURL(String url) async {
    final validUrl = url.startsWith('http') ? url : 'https://$url';
    final uri = Uri.parse(validUrl);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // ensures browser is used
    )) {
      throw 'Could not launch $uri';
    }
  }



  MediaType getMediaType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
        return MediaType('image', 'jpg');
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'pdf':
        return MediaType('application', 'pdf');
      default:
        return MediaType('application', 'octet-stream'); // fallback
    }
  }

  bool isImageUrl(String url) {
    final ext = url.toLowerCase();
    return ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png') || ext.endsWith('.gif');
  }

  bool isPdfUrl(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }


  ///Singleton factory
  static final Utils _instance = Utils._internal();

  factory Utils() {
    return _instance;
  }

  Utils._internal();
}
