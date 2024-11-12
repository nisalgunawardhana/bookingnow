import 'package:bookingnow/const/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class CustomTimePicker {
  static Future<String?> selectTime(BuildContext context) async {
    if (Platform.isIOS) {
      Duration selectedDuration = Duration.zero;

      return await showCupertinoModalPopup<String>(
        context: context,
        builder: (context) {
          return Container(
            height: 250,
            color: Colors.white, // Background color for the picker
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text(
                        'Done',
                        style: TextStyle(
                            color: kPrimaryColor), // Use your primary color
                      ),
                      onPressed: () {
                        final selectedTime = TimeOfDay(
                          hour: selectedDuration.inHours,
                          minute: selectedDuration.inMinutes % 60,
                        );
                        // Format the time to HH:MM
                        String formattedTime =
                            '${selectedTime.hour.toString().padLeft(2, '0')}:'
                            '${selectedTime.minute.toString().padLeft(2, '0')}';
                        Navigator.of(context).pop(formattedTime);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: selectedDuration,
                    onTimerDurationChanged: (Duration newDuration) {
                      selectedDuration = newDuration;
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Initialize duration for the Android picker
      Duration initialDuration = Duration.zero;

      return await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: initialDuration.inHours,
            minute: initialDuration.inMinutes % 60),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: kPrimaryColor, // Set primary color
              hintColor: kPrimaryColor, // Set hint color
              colorScheme: const ColorScheme.light(primary: kPrimaryColor),
              buttonTheme:
                  const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        },
      ).then((TimeOfDay? time) {
        if (time != null) {
          // Format the selected time to HH:MM
          return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        }
        return null; // Return null if no time was selected
      });
    }
  }
}
