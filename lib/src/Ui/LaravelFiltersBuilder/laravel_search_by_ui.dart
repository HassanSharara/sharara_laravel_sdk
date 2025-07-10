

import 'package:flutter/material.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';

class LaravelSearchByWidget extends StatefulWidget {
  const LaravelSearchByWidget({super.key,required this.provider,this.searchByLabel ="سيكون البحث بواسطة"});
  final LaravelPaginationProvider provider;
  final String searchByLabel;
  @override
  State<LaravelSearchByWidget> createState() => _LaravelSearchByWidgetState();
}
class _LaravelSearchByWidgetState extends State<LaravelSearchByWidget> {
  @override
  Widget build(BuildContext context) {
    final LaravelSearchFilter? activeFilter =
             widget
            .provider
            .searchByFilters
            .where((element) =>element.filter.active == true)
            .firstOrNull;

    if(activeFilter==null)return const SizedBox();

    return Row(
      children: [
        Expanded(
          child: RoyalTextFormField(
              title:activeFilter.filter.name,
              controller: activeFilter.controller,
              suffixIcon:ValueListenableBuilder(
                valueListenable:activeFilter.controller,
                builder:(BuildContext context,final value,_){
                  if(value.text.isEmpty && widget.provider.searchByQueryBuilder != null){
                    Future.delayed(const Duration(milliseconds:800))
                        .then((value) {
                          if(activeFilter.controller.text.isEmpty){
                            widget.provider.cancelSearchFilter();
                          }
                    });
                  }
                  return Row(
                    mainAxisSize:MainAxisSize.min,
                    children: [
                      if(activeFilter.controller.text.isNotEmpty)
                      InkWell(
                        onTap:(){activeFilter.controller.clear();},
                        borderRadius:BorderRadius.circular(15),
                        child: Padding(
                          padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),
                          child: Icon(Icons.clear,color:RoyalColors.getBodyColor(context).withValues(alpha: 0.18)),
                        ),
                      ),
                      InkWell(
                        onTap:activeFilter.controller.text.isEmpty?null:
                            ()async{
                            Navigator.maybePop(context);
                            await Future.delayed(const Duration(milliseconds:200));
                            if(activeFilter.onValueSearched!=null){
                              activeFilter.onValueSearched!(activeFilter.controller.text);
                            } else {
                              activeFilter.filter.query.clear.search(
                                activeFilter.column,
                               activeFilter.controller.text
                              );
                            }
                             widget
                                .provider
                                .searchByFilter
                              (
                                queryBuilder:
                                activeFilter
                                .filter.query
                            );
                        } ,

                        borderRadius:BorderRadius.circular(15),
                        child: Padding(
                          padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),
                          child: Icon(Icons.search,
                            color:
                            activeFilter.controller.text.isEmpty?
                                RoyalColors.mainAppColor.withValues(alpha: 0.2):
                            RoyalColors.mainAppColor,),
                        ),
                      ),

                    ],
                  );
                },
              ),
          ),
        ),
        PopupMenuButton<LaravelSearchFilter?>(
          onSelected:(final LaravelSearchFilter? f){
            if(f==null)return;
            for(final pf in  widget.provider.searchByFilters){
              if(pf.column == f.column){
                pf.filter.active = true;
              }else{
                pf.filter.active = false;
              }
            }
            setState(() {});
          },
          itemBuilder:(_)=>[
            PopupMenuItem(enabled:false,child:Text(widget.searchByLabel),),
            ...widget.provider.searchByFilters
            .map(
                  (e) =>
                  PopupMenuItem(value:e,child: Text(e.filter.name),),
            )
          ],
          child:const Icon(Icons.arrow_drop_down),
        )
      ],
    );
  }
}
