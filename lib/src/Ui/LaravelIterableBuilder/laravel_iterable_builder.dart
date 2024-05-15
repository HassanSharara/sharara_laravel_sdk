
import 'package:flutter/material.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/src/Ui/LaravelOuterFrameBuilder/laravel_loading_builder.dart';

enum IterableViewType {
  listview,
  slivers
}
class LaravelIterableBuilder<T extends GeneralLaravelModel>extends StatelessWidget {
  const LaravelIterableBuilder({super.key,
    required this.provider,
    required this.builder,
    this.scrollController,
    this.topWidgets,
    this.bottomWidgets,
    this.whenEmptyWidget,
    this.shrinkWrap = true,
    this.primary = true,
    this.reverse = true,
    this.scrollDirection = Axis.vertical,
    this.emptyWidgetSize = const Size(30,30),
    this.emptyTitle = "فارغة",
    this.viewType = IterableViewType.slivers,
  });
  final LaravelPaginationProvider<T> provider;
  final Widget Function(BuildContext,T,int) builder;
  final ScrollController? scrollController;
  final List<Widget> Function(BuildContext)? topWidgets,bottomWidgets;
  final Widget? whenEmptyWidget;
  final String emptyTitle;
  final Size emptyWidgetSize;
  final bool shrinkWrap,primary,reverse;
  final Axis scrollDirection;
  final IterableViewType viewType;
  @override
  Widget build(BuildContext context) {
    return LaravelLoadingFrameBuilder(
        provider: provider,
        child:ValueListenableBuilder(
          valueListenable:provider.notifier,
          builder:(BuildContext context,final List<T>? models,_){
            if(models==null)return const SizedBox();
            if(models.isEmpty){
              if(whenEmptyWidget!=null)return whenEmptyWidget!;
              return LayoutBuilder(
                builder:(final BuildContext context,final BoxConstraints constraints){
                  double maxWidth = constraints.maxWidth;
                  double maxHeight = constraints.maxHeight;
                  if(maxWidth.isNaN || maxHeight.isNaN)return const SizedBox();

                  if(maxHeight >= emptyWidgetSize.height && maxWidth>= emptyWidgetSize.width ){
                    maxHeight = emptyWidgetSize.height;
                    maxWidth = emptyWidgetSize.width;
                  }
                  return SizedBox(
                    height:maxHeight,
                    width:maxWidth,
                    child: Column(
                      children: [
                        const Icon(Icons.cloud),
                        Expanded(child: FittedBox(
                          child:Text(emptyTitle),
                        ))

                      ],
                    ),
                  );
                },
              );
            }
            if(viewType == IterableViewType.slivers){
              return CustomScrollView(
                scrollDirection:scrollDirection,
                controller:scrollController,
                primary:primary,
                shrinkWrap:shrinkWrap,
                reverse:reverse,
                slivers: [
                  if(topWidgets!=null)...topWidgets!(context),
                  SliverList.builder(
                    itemCount:models.length,
                    itemBuilder:(final BuildContext context,final int index){
                      final T model = models[index];
                      return builder(context,model,index);
                    },
                  ),
                  if(bottomWidgets!=null)...bottomWidgets!(context),
                ],
              );
            }
            return ListView(
              scrollDirection:scrollDirection,
              controller:scrollController,
              primary:primary,
              shrinkWrap:shrinkWrap,
              reverse:reverse,
              children: [
                if(topWidgets!=null)...topWidgets!(context),
                ListView.builder(
                  itemCount:models.length,
                  itemBuilder:(final BuildContext context,final int index){
                    final T model = models[index];
                    return builder(context,model,index);
                  },
                ),
                if(bottomWidgets!=null)...bottomWidgets!(context),
              ],
            );
          },
        ));
  }
}
