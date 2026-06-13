import 'package:flutter/material.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';

class ClinometerScreen extends StatelessWidget {
  const ClinometerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: LevoAppBar(title: "ClinometerScreen"),
      body: Center(
        child: Text("ClinometerScreen Placeholder"),
      ),
    );
  }
}
