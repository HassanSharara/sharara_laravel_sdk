
import 'package:flutter/material.dart';
import 'package:sharara_apps_building_helpers/ui.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/src/Ui/LaravelOuterFrameBuilder/laravel_loading_builder.dart';

enum IterableViewType {
  listview,
  slivers
}
class LaravelIterableBuilder<T extends GeneralLaravelModel>extends StatefulWidget {
  const LaravelIterableBuilder({super.key,
    required this.provider,
    required this.builder,
    this.scrollController,
    this.topWidgets,
    this.bottomWidgets,
    this.whenEmptyWidget,
    this.shrinkWrap = true,
    this.primary = true,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.emptyWidgetSize = const Size(30,30),
    this.emptyTitle = "فارغة",
    this.loadMoreLabel = "المزيد",
    this.viewType = IterableViewType.slivers,
    this.autoInit = false,
    this.showLoadMoreOnTheEndOfItemBuilder,
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
  final bool autoInit;
  final bool? showLoadMoreOnTheEndOfItemBuilder;
  final String loadMoreLabel;
  @override
  State<LaravelIterableBuilder<T>> createState() => _LaravelIterableBuilderState();
}

class _LaravelIterableBuilderState<T extends GeneralLaravelModel> extends State<LaravelIterableBuilder<T>> {

  @override
  void initState() {
    if(widget.autoInit)widget.provider.init();
    if ( widget.showLoadMoreOnTheEndOfItemBuilder != null ){
      widget.provider.showLoadMoreOnTheEndOfItemBuilder = widget.showLoadMoreOnTheEndOfItemBuilder!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LaravelLoadingFrameBuilder(
        provider: widget.provider,
        child:ValueListenableBuilder(
          valueListenable:widget.provider.notifier,
          builder:(BuildContext context,final List<T>? models,_){
            if(models==null)return const SizedBox();
            if(models.isEmpty){
              if(widget.whenEmptyWidget!=null)return widget.whenEmptyWidget!;
              return LayoutBuilder(
                builder:(final BuildContext context,final BoxConstraints constraints){
                  double maxWidth = constraints.maxWidth;
                  double maxHeight = constraints.maxHeight;
                  if(maxWidth.isNaN || maxHeight.isNaN)return const SizedBox();

                  if(maxHeight >= widget.emptyWidgetSize.height && maxWidth>= widget.emptyWidgetSize.width ){
                    maxHeight = widget.emptyWidgetSize.height;
                    maxWidth = widget.emptyWidgetSize.width;
                  }
                  return Center(
                    child: SizedBox(
                      height:maxHeight,
                      width:maxWidth,
                      child: Column(
                        children: [
                           Icon(Icons.cloud,
                            color:ShararaThemeController.primaryColor,),
                          Expanded(child: FittedBox(
                            child:Text(widget.emptyTitle),
                          ))
                    
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            final int itemCount = widget.provider.showLoadMoreOnTheEndOfItemBuilder?
            models.length+1:models.length;
            itemBuilder(final BuildContext context,final int index){
              if(index == models.length){
                if(!widget.provider.showLoadMoreOnTheEndOfItemBuilder
                 || widget.provider.thereIsNoMoreDataToPaginate){
                  return const SizedBox();
                }
                return Align(
                  child: ElevatedButton(
                    onPressed:()=>widget.provider.loadMore(),
                    child:Text(widget.loadMoreLabel),
                  ),
                );
              }
              final T model = models[index];
              return widget.builder(context,model,index);
            }
            if(widget.viewType == IterableViewType.slivers){
              return RefreshIndicator(
                onRefresh:()=>widget.provider.refresh(),
                child: CustomScrollView(
                  scrollDirection:widget.scrollDirection,
                  controller:widget.scrollController,
                  primary:widget.primary,
                  shrinkWrap:widget.shrinkWrap,
                  reverse:widget.reverse,
                  slivers: [
                    if(widget.topWidgets!=null)...widget.topWidgets!(context),
                    SliverList.builder(
                      key:UniqueKey(),
                      itemCount:itemCount,
                      itemBuilder:itemBuilder,
                    ),
                    if(widget.bottomWidgets!=null)...widget.bottomWidgets!(context),
                  ],
                ),
              );
            }
            return ListView(
              scrollDirection:widget.scrollDirection,
              controller:widget.scrollController,
              primary:widget.primary,
              shrinkWrap:widget.shrinkWrap,
              reverse:widget.reverse,
              children: [
                if(widget.topWidgets!=null)...widget.topWidgets!(context),
                ListView.builder(
                  key:UniqueKey(),
                  shrinkWrap:true,
                  primary:false,
                  itemCount:itemCount,
                  itemBuilder:itemBuilder,
                ),
                if(widget.bottomWidgets!=null)...widget.bottomWidgets!(context),
              ],
            );
          },
        ));
  }
}
