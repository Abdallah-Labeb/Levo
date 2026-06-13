import 'package:flutter/material.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';

class VibrationMeterScreen extends StatelessWidget {
  const VibrationMeterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: LevoAppBar(title: "VibrationMeterScreen"),
      body: Center(
        child: Text("VibrationMeterScreen Placeholder"),
      ),
    );
  }
}
