
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
  this.back = "رجوع",
  this.searchByLabel = "سيكون البحث بواسطة",
    this.gridDelegate
  });
  final LaravelPaginationProvider provider;
  final String filteringLabel,searchLabel,back,searchByLabel,cancelFiltersLabel;
  final SliverGridDelegate? gridDelegate;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:ShararaDirectionalityController.direction,
      child: ListView(
        padding:const EdgeInsets.symmetric(vertical:12,horizontal:8),
        children: [
          LaravelSearchByWidget(provider: provider,searchByLabel:searchByLabel,),
          const SizedBox(height: 10,),
          RestFilters(provider:provider,gridDelegate:gridDelegate,),
          const SizedBox(height:20,),
          ElevatedButton(
              style: ButtonStyle(
                shadowColor:WidgetStateColor.resolveWith((_)=>RoyalColors.mainAppColor)
                ),
              onPressed:()async{
                 Navigator.maybePop(context);
                 await Future.delayed(const Duration(milliseconds:150));
                 await provider.filteringByPF();
                }, child:Text(filteringLabel)
          ),
          ElevatedButton(
              style:ButtonStyle(
                foregroundColor:WidgetStateColor.resolveWith((_) =>
                 RoyalColors.greyFaintColor
                )
              ),
              onPressed:()async {
              Navigator.maybePop(context);
              await Future.delayed(const Duration(milliseconds:150));
              provider.cancelAllFilters();
              },
              child: Text(cancelFiltersLabel)),
          const SizedBox(height:10,),

          TextButton(onPressed: ()=>Navigator.pop(context), child: Text(back)),
          const SizedBox(height:10,),
        ],
      ),
    );
  }
}

class RestFilters extends StatefulWidget {
  const RestFilters({super.key,
  required this.provider,
    this.gridDelegate
  });
  final LaravelPaginationProvider provider;
  final SliverGridDelegate? gridDelegate;
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

    return GridView.builder(
        primary:false,
        shrinkWrap:true,
        gridDelegate: widget.gridDelegate ?? const
         SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200,
          childAspectRatio: 3
         )
        ,
        itemCount:widget.provider.filters.length,
        itemBuilder: (context,final int index){
        final filter = widget.provider.filters[index];
        return     Align(
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
        );
        });
  }
}



