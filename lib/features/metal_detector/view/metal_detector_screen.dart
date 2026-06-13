import 'package:flutter/material.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';

class MetalDetectorScreen extends StatelessWidget {
  const MetalDetectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: LevoAppBar(title: "MetalDetectorScreen"),
      body: Center(
        child: Text("MetalDetectorScreen Placeholder"),
      ),
    );
  }
}
