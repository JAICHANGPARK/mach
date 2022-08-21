import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:mach/src/ui/screen/mach_main_screen.dart';

class MachApp extends StatelessWidget {
  const MachApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return const FluentApp(
        home: MachMainScreen(),
      );
    }
    return const MaterialApp(
      home: MachMainScreen(),
    );
  }
}
