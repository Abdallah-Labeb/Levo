import 'package:flutter/material.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';

class LightMeterScreen extends StatelessWidget {
  const LightMeterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: LevoAppBar(title: "LightMeterScreen"),
      body: Center(
        child: Text("LightMeterScreen Placeholder"),
      ),
    );
  }
}
