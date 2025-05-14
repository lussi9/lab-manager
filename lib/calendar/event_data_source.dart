import 'dart:ui';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:lab_manager/calendar/event.dart';
import 'package:flutter/material.dart';

class EventDataSource extends CalendarDataSource{
  EventDataSource(List<Event> events){
    appointments = events;
  }

  Event getEvent(int index) => appointments![index] as Event;

  @override
  DateTime getStartTime(int index) => getEvent(index).from;

  @override
  DateTime getEndTime(int index) => getEvent(index).to;

  @override
  String getSubject(int index) => getEvent(index).title;

  @override
  String getNotes(int index) => getEvent(index).description;

  @override
  Color getColor(int index) => getEvent(index).background;

  @override
  bool isAllDay(int index) => getEvent(index).isAllDay;

  @override
  String getRecurrenceRule(int index) => appointments![index].recurrenceRule;

}