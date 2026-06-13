import 'package:flutter/material.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';

class UnitConverterScreen extends StatelessWidget {
  const UnitConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: LevoAppBar(title: "UnitConverterScreen"),
      body: Center(
        child: Text("UnitConverterScreen Placeholder"),
      ),
    );
  }
}
