import 'package:lab_manager/model/event_data_source.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:provider/provider.dart';
import '../provider/event_provider.dart';

class CalendarWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;

    return SfCalendar(
      view: CalendarView.month,
      dataSource: EventDataSource(events),
      initialSelectedDate: DateTime.now(),
    );
  }
}