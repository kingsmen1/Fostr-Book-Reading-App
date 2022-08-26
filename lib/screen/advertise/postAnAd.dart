
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/services/StorageService.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/FilePicker.dart';
import 'package:fostr/utils/theme.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


const registerInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.all(20),
  border: InputBorder.none,
  hintStyle: TextStyle(fontSize: 15, color:Colors.black),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.all(Radius.circular(9)),
  ),
  disabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.all(Radius.circular(9)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.all(Radius.circular(9)),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.all(Radius.circular(9)),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.all(Radius.circular(9)),
  ),
  filled: true,
  fillColor: Color(0xffe5e5e5),
);
