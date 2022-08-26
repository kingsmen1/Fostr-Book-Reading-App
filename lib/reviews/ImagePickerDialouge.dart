import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fostr/services/FilePicker.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

imagePickerDialoge(context, {required Function(File) onImageSelected}) {
  File? croppedfile;
  Map<String, dynamic> file;

  return showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        height: 100,
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border:
                Border.all(color: GlobalColors.signUpSignInButton, width: 0.5)),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //camera
              GestureDetector(
                onTap: () async {
                  try {
                    var clickedfile = await ImagePicker()
                        .pickImage(source: ImageSource.camera);
                    assert(clickedfile?.path != null);
                    File image = File(clickedfile?.path ?? "");

                    if (image.path.split(".").last == "jpeg" ||
                        image.path.split(".").last == "jpg") {
                      if (image != null) {
                        croppedfile = await ImageCropper().cropImage(
                            sourcePath: image.path,
                            aspectRatioPresets: [
                              CropAspectRatioPreset.square,
                              CropAspectRatioPreset.ratio3x2,
                              CropAspectRatioPreset.original,
                              CropAspectRatioPreset.ratio4x3,
                              CropAspectRatioPreset.ratio16x9
                            ],
                            androidUiSettings: AndroidUiSettings(
                                toolbarTitle: 'Image Cropper',
                                toolbarColor: GlobalColors.signUpSignInButton,
                                toolbarWidgetColor: Colors.black,
                                initAspectRatio: CropAspectRatioPreset.original,
                                lockAspectRatio: false),
                            iosUiSettings: IOSUiSettings(
                              minimumAspectRatio: 1.0,
                            ));
                        if (croppedfile != null) {
                          await FlutterImageCompress.compressAndGetFile(
                            croppedfile!.path,
                            image.path,
                            quality: 80, // the lesser the poorer the
                          ).then((value) {
                            if (value != null) {
                              onImageSelected(value);
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          });
                        }
                      } else {
                        ToastMessege("Image not uploaded",context: context);
                      }
                    } else {
                      ToastMessege("Only .jpeg/.jpg formats allowed",context: context);
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: GlobalColors.signUpSignInButton,
                      size: 40,
                    ),
                  ],
                ),
              ),

              Container(
                height: 80,
                width: 0.5,
                color: GlobalColors.signUpSignInButton,
              ),

              //gallery
              GestureDetector(
                onTap: () async {
                  try {
                    file = await Files.getFile();

                    if (file['file'].path.split(".").last == "jpeg" ||
                        file['file'].path.split(".").last == "jpg") {
                      if (file['file'] != null) {
                        croppedfile = await ImageCropper().cropImage(
                            sourcePath: file['file'].path,
                            aspectRatioPresets: [
                              CropAspectRatioPreset.square,
                              CropAspectRatioPreset.ratio3x2,
                              CropAspectRatioPreset.original,
                              CropAspectRatioPreset.ratio4x3,
                              CropAspectRatioPreset.ratio16x9
                            ],
                            androidUiSettings: AndroidUiSettings(
                                toolbarTitle: 'Image Cropper',
                                toolbarColor: GlobalColors.signUpSignInButton,
                                toolbarWidgetColor: Colors.black,
                                initAspectRatio: CropAspectRatioPreset.original,
                                lockAspectRatio: false),
                            iosUiSettings: IOSUiSettings(
                              minimumAspectRatio: 1.0,
                            ));
                        if (croppedfile != null) {
                          await FlutterImageCompress.compressAndGetFile(
                            croppedfile!.path,
                            file['file'].path,
                            quality: 50,
                          ).then((value) {
                            if (value != null) {
                              onImageSelected(value);
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          });
                        }
                      } else {
                        ToastMessege("Image not uploaded",context: context);
                      }
                    } else {
                      ToastMessege("Only .jpeg/.jpg formats allowed",context: context);
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apps_rounded,
                      color: GlobalColors.signUpSignInButton,
                      size: 40,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
