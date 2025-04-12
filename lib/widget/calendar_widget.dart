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
      todayHighlightColor: Color.fromARGB(255, 137, 240, 117),
      selectionDecoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Color.fromARGB(255, 137, 240, 117), width: 2),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      firstDayOfWeek: 1, //Lunes primer dia de la semana
      dataSource: EventDataSource(events), //DataSource para el calendario
      initialSelectedDate: DateTime.now(), //Fecha seleccionada por defecto
      allowViewNavigation: true, //Permitir navegar entre vistas
      showTodayButton: true, //Mostrar boton de hoy
      showDatePickerButton: true, //Mostrar boton de seleccion de fecha
      allowedViews: <CalendarView>
        [
          CalendarView.day,
          CalendarView.week,
          CalendarView.workWeek,
          CalendarView.month,
          CalendarView.schedule
        ],
      //viewNavigationMode: ViewNavigationMode.snap,
      monthViewSettings: MonthViewSettings(
        numberOfWeeksInView: 5,
        showAgenda: true,
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
      appointmentTextStyle: TextStyle(
        fontSize: 12
      ),
      appointmentTimeTextFormat: 'HH:mm',
    );
  }
}