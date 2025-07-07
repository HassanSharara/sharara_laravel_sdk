

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';

class LaravelCachedImage extends StatelessWidget {
  const LaravelCachedImage({super.key,
   this.model,
   this.url,
   this.width,
   this.height,
   this.radius,
   this.fit,
   this.child,
   this.errorWidget,
   this.shape = BoxShape.rectangle,
   this.borderRadius,
  });
  final GeneralLaravelModel? model;
  final String? url;
  final double? height,width,radius;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget,child;
  final BoxShape shape;
  @override
  Widget build(BuildContext context) {
    final String? imageUrl = url ?? model?.modelImageUrl;
    final Widget eWidget = Align(child:SizedBox(
      width:width,
      height:height,
      child: errorWidget ?? const Center(
        child: Icon(Icons.image),
      ),
    ));
    if(imageUrl == null)return eWidget;
    if(height == null || width == null ){
      return CachedNetworkImage(
        key:UniqueKey(),
        imageUrl: imageUrl ,
        progressIndicatorBuilder:(BuildContext context,_,p){
          return Center(
            child: ConstrainedBox(
              constraints:const BoxConstraints(
                maxHeight:14,
                maxWidth:20,
              ),
              child:const LinearProgressIndicator(),
            ),
          );
        },
        errorWidget:(_,__,___){
          return eWidget;
        },
        imageBuilder:(BuildContext context,final ImageProvider provider){
          return Container(
            width:width,
            height:height,
            decoration:BoxDecoration(
                shape:shape,
                borderRadius:shape==BoxShape.circle?null:borderRadius ?? BorderRadius.circular(radius??15),
                image:DecorationImage(
                    image:provider,
                    fit:fit??BoxFit.fill
                )
            ),
            child:child,
          );
        },
      );
    }
    return Container(
      constraints: BoxConstraints(
        maxHeight: height! ,
        maxWidth:width !,
      ),
      child:CachedNetworkImage(
        key:UniqueKey(),
        imageUrl: imageUrl ,
        progressIndicatorBuilder:(BuildContext context,_,p){
          return Center(
            child: ConstrainedBox(
              constraints:const BoxConstraints(
                maxHeight:14,
                maxWidth:20,
              ),
              child:const LinearProgressIndicator(),
            ),
          );
        },
        errorWidget:(_,__,___){
          return eWidget;
        },
        imageBuilder:(BuildContext context,final ImageProvider provider){
          return Container(
            width:width,
            height:height,
            decoration:BoxDecoration(
                shape:shape,
                borderRadius:shape==BoxShape.circle?null:borderRadius ?? BorderRadius.circular(radius??15),
                image:DecorationImage(
                    image:provider,
                    fit:fit??BoxFit.fill
                )
            ),
            child:child,
          );
        },
      ),
    );
  }
}
