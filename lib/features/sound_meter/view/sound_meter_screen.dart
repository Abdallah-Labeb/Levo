import 'package:flutter/material.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';

class SoundMeterScreen extends StatelessWidget {
  const SoundMeterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: LevoAppBar(title: "SoundMeterScreen"),
      body: Center(
        child: Text("SoundMeterScreen Placeholder"),
      ),
    );
  }
}
