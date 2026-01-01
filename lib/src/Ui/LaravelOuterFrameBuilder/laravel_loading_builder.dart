

import 'package:flutter/material.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';

class LaravelLoadingFrameBuilder extends StatelessWidget {
  const LaravelLoadingFrameBuilder({super.key,
  required this.provider,
  required this.child,
    this.showLoading = true
  });
  final LaravelPaginationProvider provider;
  final Widget child;
  final bool showLoading ;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        child,

        if(showLoading)
        ValueListenableBuilder(valueListenable: provider.loading,
            child:const SizedBox(),
            builder:(BuildContext context,final bool isLoading,c){
             if(!isLoading)return c!;
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
