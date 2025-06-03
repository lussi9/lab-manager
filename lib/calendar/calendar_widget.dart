import 'package:lab_manager/calendar/event_data_source.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:provider/provider.dart';
import 'package:lab_manager/calendar/event_editing_page.dart';
import 'package:lab_manager/calendar/event.dart';

class CalendarWidget extends StatefulWidget{
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  State<CalendarWidget> createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget>{
  CalendarController calendarController = CalendarController();
  Event? _selectedEvent;

  @override
  void initState() {
    _selectedEvent = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<List<Event>>(context);

    return SfCalendar(
      view: CalendarView.month,
      controller: calendarController,
      todayHighlightColor: Theme.of(context).colorScheme.primary,
      selectionDecoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      firstDayOfWeek: 1, //Lunes primer dia de la semana
      dataSource: EventDataSource(events), //DataSource para el calendario
      initialSelectedDate: DateTime.now(), //Fecha seleccionada por defecto
      allowViewNavigation: true, //Permitir navegar entre vistas
      showTodayButton: true, //Mostrar boton de hoy
      showDatePickerButton: true, //Mostrar boton de seleccion de fecha
      allowedViews: <CalendarView> //Vistas permitidas
        [
          CalendarView.day,
          CalendarView.week,
          CalendarView.workWeek,
          CalendarView.month,
          CalendarView.schedule
        ],
      monthViewSettings: MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        numberOfWeeksInView: getNumberOfWeeks() //Numero de semanas flexible
        ),
      scheduleViewSettings: ScheduleViewSettings(
        appointmentItemHeight: 50),
      appointmentTextStyle: TextStyle(fontSize: 14),
      appointmentTimeTextFormat: 'HH:mm',
      onTap: calendarTapped,
      onLongPress: (CalendarLongPressDetails details) {
        if (details.targetElement == CalendarElement.calendarCell) {
          setState(() {
            Navigator.push<Widget>(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => EventEditingPage()),
            );
          });
        }
      },
    );
  }

  void calendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment) {
      setState(() {
        final Event eventDetails = details.appointments![0];
        _selectedEvent = eventDetails;
        Navigator.push<Widget>(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => EventEditingPage(selectedEvent: _selectedEvent)),
        );
      });
    }
  }

  int getNumberOfWeeks() {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight > 800) {
      return 6; // Show more weeks on taller screens
    } else if (screenHeight > 600) {
      return 5;
    } else {
      return 4; // Default for smaller screens
    }
  }
}