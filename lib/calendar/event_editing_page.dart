import 'package:lab_manager/objects/notification.dart';
import 'event.dart';
import 'package:flutter/material.dart';
import 'package:lab_manager/utils.dart';
import 'package:provider/provider.dart';
import 'event_provider.dart';

class EventEditingPage extends StatefulWidget{
  final Event? selectedEvent;

  EventEditingPage({
    Key? key,
    this.selectedEvent,
  }) : super(key: key);

  @override
  _EventEditingPageState createState() => _EventEditingPageState();
}

class _EventEditingPageState extends State<EventEditingPage>{
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descController = TextEditingController();
  late DateTime fromDate;
  late DateTime toDate;
  bool _isAllDay = false;
  bool _receiveNotification = false;

  final List<Color> _colorCollection = [
    Colors.red,
    Colors.blue,
    Color.fromRGBO(67, 160, 71, 1),
    Colors.yellow,
    Colors.orange,
  ];

  final List<String> _colorNames = [
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Orange',
  ];

  int _selectedColorIndex = 0;

  @override
  void initState(){
    super.initState();
    final calendarProvider = Provider.of<EventProvider>(context, listen: false);
    calendarProvider.loadEvents();
    if(widget.selectedEvent == null){
      fromDate = DateTime.now();
      toDate = DateTime.now().add(Duration(hours: 2));
    } else{
      final event = widget.selectedEvent!;
      titleController.text = event.title;
      descController.text = event.description;
      fromDate = event.from;
      toDate = event.to;
      _isAllDay = event.isAllDay;
      _receiveNotification = event.notification;

    final existingColorIndex = _colorCollection.indexWhere(
      (color) => color.value == event.background.value
    );
    if (existingColorIndex != -1) {
      _selectedColorIndex = existingColorIndex; // <-- Fix for incorrect color
    }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Color.fromRGBO(67, 160, 71, 1),
      title: Text('Event details'),
      leading: CloseButton(),
      actions: buildEditingActions(),
    ),
    body: Container(
      padding: EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: <Widget>[
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              leading: const Text(''),
              title: TextFormField(
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                cursorColor: Color.fromRGBO(67, 160, 71, 1),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add Title',
                ),
                onFieldSubmitted: (_) => saveForm(),
                validator: (title) =>
                  title != null && title.isEmpty ? 'Title cannot be empty' : null,
                controller: titleController,
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile( //All day
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: Icon(
                Icons.access_time,
                color: Colors.grey,
              ),
              title: Row(children: <Widget>[
                const Expanded(
                  child: Text('All day', style: TextStyle(fontSize: 18),),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Switch(
                      value: _isAllDay,
                      activeColor: Color.fromRGBO(67, 160, 71, 1),
                      onChanged: (bool value) {
                        setState(() {
                          _isAllDay = value;
                        });
                      },
                    ))),
              ])),
            ListTile( //from date
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: const Text(''),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                      child: Text(
                        Utils.toDate(fromDate),
                        textAlign: TextAlign.left),
                      onTap: () async {
                        pickFromDateTime(pickDate: true);
                      }),
                  ),
                  Expanded(
                    flex: 3,
                    child: _isAllDay
                      ? const Text('')
                      : GestureDetector(
                        child: Text(
                          Utils.toTime(fromDate),
                          textAlign: TextAlign.right,
                        ),
                        onTap: () async {
                          pickFromDateTime(pickDate: false);
                        })),
              ])),
            ListTile( //to date
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: const Text(''),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                        child: Text(
                          Utils.toDate(toDate),
                          textAlign: TextAlign.left,
                        ),
                        onTap: () async {
                          pickToDateTime(pickDate: true);
                        }),
                  ),
                  Expanded(
                    flex: 3,
                    child: _isAllDay
                      ? const Text('')
                      : GestureDetector(
                        child: Text(
                          Utils.toTime(toDate),
                          textAlign: TextAlign.right,
                        ),
                        onTap: () async {
                          pickToDateTime(pickDate: false);
                        })),     
                  ])),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: Icon(Icons.lens,
                  color: _colorCollection[_selectedColorIndex]),
              title: Text(
                _colorNames[_selectedColorIndex],
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                showDialog<Widget>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Pick a Color'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_colorCollection.length, (index) {
                            return ListTile(
                              leading: Icon(Icons.lens, color: _colorCollection[index]),
                              title: Text(_colorNames[index]),
                              onTap: () {
                                setState(() {
                                  _selectedColorIndex = index;
                                });
                                Navigator.of(context).pop();
                              },
                            );
                          }),
                        ),
                      ),
                    );
                  },
                ).then((dynamic value) => setState(() {}));
              },
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
              contentPadding: const EdgeInsets.all(5),
              leading: Icon(
                Icons.subject,
                color: Colors.grey,
              ),
              title: TextFormField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add a description',
                  hintStyle: TextStyle(
                    fontSize: 18,
                  ),
                ),
                controller: descController,
                onFieldSubmitted: (_) => saveForm(),
              )
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
              contentPadding: const EdgeInsets.all(5),
              leading: Icon(
                Icons.notifications,
                color: Colors.grey,
              ),
              title: Row(children: <Widget>[
                const Expanded(
                  child: Text('Receive notification', style: TextStyle(fontSize: 18),),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Switch(
                      value: _receiveNotification,
                      activeColor: Color.fromRGBO(67, 160, 71, 1),
                      onChanged: (bool value) {
                        setState(() {
                          _receiveNotification = value;
                          if(_receiveNotification){
                            NotificationService().showNotification(
                              id: 0,
                              title: 'Event Reminder',
                              body: 'You have an event scheduled for ${Utils.toDate(fromDate)} at ${Utils.toTime(fromDate)}',
                            );
                          }
                        });
                      },
                    ))),
              ])),
          ],
        ),
      ),
    ),
    floatingActionButton: widget.selectedEvent == null
    ? const Text(''): FloatingActionButton(
      onPressed: () {
        final provider = Provider.of<EventProvider>(context, listen: false);
        if (widget.selectedEvent != null) {
          provider.deleteEvent(widget.selectedEvent!);
          Navigator.pop(context);
        }
      },
      backgroundColor: Colors.red,
      child:
        const Icon(Icons.delete_outline, color: Colors.white),
    ),
  );

  List<Widget> buildEditingActions()=> [
    IconButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconColor: Colors.white,
        iconSize: 22,
      ),
      onPressed: saveForm,
      icon: Icon(Icons.done),
    ),
    SizedBox(width: 12),
  ];

  Future pickFromDateTime({required bool pickDate}) async{
    final date = await pickDateTime(fromDate, pickDate: pickDate);
    if(date == null) return;

    if(date.isAfter(toDate)){
      toDate = DateTime(date.year, date.month, date.day, toDate.hour, toDate.minute);
    }

    setState(() => fromDate = date);
  }

  Future pickToDateTime({required bool pickDate}) async{
    final date = await pickDateTime(
      toDate, 
      pickDate: pickDate,
      firstDate: pickDate? fromDate : null,);
    if(date == null) return;

    if (date.isBefore(fromDate)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('The end date cannot be prior to the start date.')),
    );
    return;
  }

    setState(() => toDate = date);
  }

  Future<DateTime?> pickDateTime(
    DateTime initialDate, {
    required bool pickDate,
    DateTime? firstDate,
  }) async{
    if(pickDate){
      final date = await showDatePicker(
        context: context, 
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(2015, 8), 
        lastDate: DateTime(2101),
      );

      if(date == null) return null;

      final time = Duration(hours: initialDate.hour, minutes: initialDate.minute);
      return date.add(time);
    } else{
      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if(timeOfDay == null) return null;

      final date = DateTime(initialDate.year, initialDate.month, initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);

      return date.add(time);
    }
  }

  Future saveForm() async{
    final isValid = _formKey.currentState!.validate();
    if(isValid){
      final event = Event(
        documentId: widget.selectedEvent?.documentId,
        title: titleController.text,
        description: descController.text,
        from: fromDate,
        to: toDate,
        background: _colorCollection[_selectedColorIndex],
        isAllDay: _isAllDay,
        notification: _receiveNotification,
      );

      final isEditing = widget.selectedEvent != null;
      final provider = Provider.of<EventProvider>(context, listen: false);

      if(isEditing){
        provider.editEvent(widget.selectedEvent!, event);
      } else{
        provider.addEvent(event);
      }
      Navigator.of(context).pop();
    }
  }
}