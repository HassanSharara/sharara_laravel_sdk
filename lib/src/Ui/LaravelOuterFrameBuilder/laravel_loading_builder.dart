

import 'package:flutter/material.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';

class LaravelLoadingFrameBuilder extends StatelessWidget {
  const LaravelLoadingFrameBuilder({super.key,
  required this.provider,
  required this.child
  });
  final LaravelPaginationProvider provider;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        child,
        ValueListenableBuilder(valueListenable: provider.loading,
            child:const SizedBox(),
            builder:(BuildContext context,final bool isLoading,_){
             if(!isLoading)return _!;
             return  Align(
               alignment:const Alignment(0,0.95),
               child: SizedBox(
                   width:size.width,
                   child:const LinearProgressIndicator()),
             );
            })
      ],
    );
  }
}
