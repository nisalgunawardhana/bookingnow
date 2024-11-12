import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomPicker {
  static void show(
      BuildContext context, List<String> items, Function(String) onSelected) {
    if (Platform.isIOS) {
      _showCupertinoPicker(context, items, onSelected);
    } else {
      _showMaterialPicker(context, items, onSelected);
    }
  }

  static void _showCupertinoPicker(
      BuildContext context, List<String> items, Function(String) onSelected) {
    int selectedIndex = 0;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child:
                      const Text('Done', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    onSelected(
                        items[selectedIndex]); // Return the selected item
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  selectedIndex = index; // Update the selected index
                },
                children: items.map((item) {
                  return Center(
                    child: Text(item,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 0, 2, 3), fontSize: 16)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showMaterialPicker(
      BuildContext context, List<String> items, Function(String) onSelected) {
    int selectedIndex = 0; // Track the selected index

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title:
              const Text('Select one', style: TextStyle(color: Colors.black)),
          content: SizedBox(
            width: 300,
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return ListBody(
                    children: List.generate(items.length, (index) {
                      return RadioListTile<int>(
                        title: Text(items[index],
                            style: const TextStyle(color: Colors.black)),
                        value: index, // Use the index as the value
                        groupValue: selectedIndex,
                        onChanged: (value) {
                          setState(() {
                            selectedIndex = value!; // Update the selected index
                          });
                        },
                      );
                    }),
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                onSelected(items[selectedIndex]); // Return the selected item
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
