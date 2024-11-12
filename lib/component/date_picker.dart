import 'package:bookingnow/const/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class CustomDatePicker {
  static Future<DateTime?> selectDate(BuildContext context) async {
    if (Platform.isIOS) {
      return await showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (context) {
          DateTime now = DateTime.now();
          DateTime selectedDate = now;

          return Container(
            height: 300,
            color: Colors.white, // Set background to white
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Done',
                          style: TextStyle(
                              color: kSecondaryColor)), // Use primary color
                      onPressed: () {
                        Navigator.of(context).pop(selectedDate);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    initialDateTime: selectedDate,
                    onDateTimeChanged: (DateTime newDate) {
                      selectedDate = newDate;
                    },
                    mode: CupertinoDatePickerMode.date,
                    backgroundColor: Colors.white, // Background color
                    minimumDate: now, // Optional: set a minimum date
                    use24hFormat: false,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: kPrimaryColor, // Set primary color
              hintColor: kPrimaryColor,
              colorScheme: const ColorScheme.light(primary: kPrimaryColor),
              buttonTheme:
                  const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        },
      );
    }
  }
}
