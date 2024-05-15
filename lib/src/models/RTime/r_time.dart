

import 'package:flutter/material.dart';

class RTime {
  DateTime? dateTime;
  TimeOfDay? timeOfDay;
  RTime.fromJson(json,{final String columnName = "created_at"}){
    if(json is Map  && json.containsKey(columnName)){
      try {
        dateTime = DateTime.parse(json[columnName].toString());
      }
      catch(_){}

      if(dateTime!=null){
        dateTime=dateTime!.add(const Duration(hours:3));
        timeOfDay=TimeOfDay.fromDateTime(dateTime!);
      }
    }
  }
  RTime.fromDateTime(this.dateTime){
    timeOfDay = TimeOfDay.fromDateTime(dateTime!);
  }
  bool isAfter(RTime d){
    return dateTime?.isAfter(d.dateTime!) == true;
  }
  bool isBefore(RTime d){
    return dateTime?.isBefore(d.dateTime!) == true;
  }
  String date([final String splitter = " - "]){
    if(dateTime != null ){
      return "${dateTime!.year}$splitter${dateTime!.month}$splitter${dateTime!.day}";
    }
    return'';
  }
  String timeOfDayAsValidString(){
    if(dateTime != null ){
      return "${timeOfDay!.period.name}   ${timeOfDay!.hourOfPeriod}: ${dateTime!.minute} ";
    }
    return'';
  }
}