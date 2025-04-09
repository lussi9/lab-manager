import 'package:lab_manager/model/event.dart';
import 'package:lab_manager/page/event_editing_page.dart';
import 'package:lab_manager/provider/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:lab_manager/utils.dart';
import 'package:provider/provider.dart';

class EventViewingPage extends StatelessWidget{
  final Event event;

  const EventViewingPage({
    Key? key, 
    required this.event
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        actions: buildViewingActions(context, event),
      ),
      body: ListView(
        padding: EdgeInsets.all(32),
        children: <Widget>[
          buildDateTime(event),
          SizedBox(height: 32),
          Text(
            event.title,
            style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          Text(
            event.description,
            style: TextStyle( color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget buildDateTime(Event event) {
    return Column(
      children: [
        buildDate('From', event.from),
        buildDate('To', event.to),
      ],
    );
  }

  Widget buildDate(String title, DateTime date) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        title,
        style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),
      ),
      Text(
        Utils.toDate(date),
        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ],
  );

  List<Widget> buildViewingActions(BuildContext context, Event event) => [
    IconButton(
      icon: Icon(Icons.edit),
      onPressed: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => EventEditingPage(event: event),
        ),
      ),
    ),
    IconButton(
      icon: Icon(Icons.delete),
      onPressed: () {
        final provider = Provider.of<EventProvider>(context, listen: false);
        
        provider.deleteEvent(event);
        Navigator.of(context).pop();
      }
    ),
  ];
}