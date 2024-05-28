
import 'package:flutter/material.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/ui.dart';

class LaravelFiltersUiBuilder extends StatelessWidget {
  static showFilter(final BuildContext context,final LaravelPaginationProvider provider){
    showModalBottomSheet(context: context, builder:(_)
     => LaravelFiltersUiBuilder(provider: provider)
    );
  }
  const LaravelFiltersUiBuilder({super.key,
  required this.provider,
  this.filteringLabel = "فلترة",
  this.cancelFiltersLabel = "الغاء الفلترة",
  this.searchLabel = "بحث",
  this.searchByLabel = "سيكون البحث بواسطة"
  });
  final LaravelPaginationProvider provider;
  final String filteringLabel,searchLabel,searchByLabel,cancelFiltersLabel;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:ShararaDirectionalityController.direction,
      child: ListView(
        padding:const EdgeInsets.symmetric(vertical:12,horizontal:8),
        children: [
          LaravelSearchByWidget(provider: provider,searchByLabel:searchByLabel,),
          RestFilters(provider:provider,),
          ElevatedButton(
              style: ButtonStyle(
                shadowColor:MaterialStateColor.resolveWith((states) =>
                 RoyalColors.mainAppColor
                )
              ),
              onPressed:()async{
                 Navigator.maybePop(context);
                 await Future.delayed(const Duration(milliseconds:150));
                 await provider.filteringByPF();
                }, child:Text(filteringLabel)
          ),

          ElevatedButton(
              style:ButtonStyle(
                foregroundColor:MaterialStateColor.resolveWith((states) =>
                 RoyalColors.red
                )
              ),
              onPressed:()async {
              Navigator.maybePop(context);
              await Future.delayed(const Duration(milliseconds:150));
              provider.cancelAllFilters();
              },
              child: Text(cancelFiltersLabel))
        ],
      ),
    );
  }
}

class RestFilters extends StatefulWidget {
  const RestFilters({super.key,
  required this.provider
  });
  final LaravelPaginationProvider provider;
  @override
  State<RestFilters> createState() => _RestFiltersState();
}

class _RestFiltersState extends State<RestFilters> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return
      GridView.extent(
        shrinkWrap:true,
        primary:false,
        maxCrossAxisExtent:200,
        children: [
          for(final filter in widget.provider.filters)
            Align(
              child: InkWell(
                onTap:()=>setState(() {
                  filter.active = !filter.active;
                }),
                borderRadius:BorderRadius.circular(15),
                child: RoyalShadowContainer(
                  backgroundColor:filter.active?RoyalColors.mainAppColor:null,
                  height:45,
                  margin:const EdgeInsets.symmetric(horizontal:8,vertical:8),
                  child:Center(
                    child: Text(
                      filter.name,
                      textAlign:TextAlign.center,
                      style:TextStyle(
                        color:filter.active?RoyalColors.white:null
                      ),
                    ),
                  ),
                ),
              ),
            )
        ],
      );
  }
}



