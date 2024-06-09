

import 'package:flutter/material.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';

class LiBuilder extends StatelessWidget {
  const LiBuilder({super.key,required this.builder});
  final Widget Function(BuildContext,LaravelConfigurations) builder;
  @override
  Widget build(BuildContext context) {
    if(LaravelConfigurations.configurations==null)return const SizedBox();
    return builder(context,LaravelConfigurations.configurations!);
  }
}
