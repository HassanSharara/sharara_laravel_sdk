

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';

void main()async{
  await Hive.initFlutter();
  await ShararaAppHelperInitializer.initialize();
  runApp( const FirstScreen());
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShararaAppHelper(
      builder:(_)=>Scaffold(
        body:Center(
          child:RoyalRoundedButton(
            title: "test",
            onPressed:(){

            },
          ),
        ),
      ),
    );
  }
}
