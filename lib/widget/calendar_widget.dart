import 'package:lab_manager/model/event_data_source.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:provider/provider.dart';
import '../provider/event_provider.dart';
import 'package:lab_manager/page/event_editing_page.dart';
import 'package:lab_manager/model/event.dart';

class CalendarWidget extends StatefulWidget{
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  State<CalendarWidget> createState() => CalendarWidgetState();
}

List<Color> _colorCollection = <Color>[];
Event? _selectedEvent;
String _title = '';
String _description = '';
late DateTime _fromDate;
late DateTime _toDate;
bool _isAllDay = false;
int _selectedColorIndex = 0;

class CalendarWidgetState extends State<CalendarWidget>{
  CalendarController calendarController = CalendarController();

  @override
  void initState() {
    Provider.of<EventProvider>(context, listen: false).loadEvents();
    _selectedEvent = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;
    return SfCalendar(
      view: CalendarView.month,
      controller: calendarController,
      todayHighlightColor: Colors.green[800],
      todayTextStyle: TextStyle(
        color: Colors.white,
      ),
      selectionDecoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: const Color.fromRGBO(46, 125, 50, 1), width: 2),
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
      onTap: calendarTapped,
    );
  }

  void calendarTapped(CalendarTapDetails details) {
    if (details.targetElement != CalendarElement.calendarCell &&
        details.targetElement != CalendarElement.appointment) {
      return;
    }
    setState(() {
      _selectedEvent = null;
      _isAllDay = false;
      _selectedColorIndex = 0;
      _title = '';
      _description = '';
      if (calendarController.view == CalendarView.month) {
        calendarController.view = CalendarView.day;
      } else {
        if (details.appointments != null &&
            details.appointments!.length == 1) {
          final Event eventDetails = details.appointments![0];
          _fromDate = eventDetails.from;
          _toDate = eventDetails.to;
          _isAllDay = eventDetails.isAllDay;
          _selectedColorIndex = _colorCollection.indexOf(eventDetails.background);
          _title = eventDetails.title;
          _description = eventDetails.description;
          _selectedEvent = eventDetails;
        } else {
          final DateTime date = details.date!;
          _fromDate = date;
          _toDate = date.add(const Duration(hours: 1));
        }
        Navigator.push<Widget>(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => EventEditingPage(selectedEvent: _selectedEvent)),
        );
      }
    });
  }
}