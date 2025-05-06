import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/entry.dart';
import '../page/entry_editing_page.dart';
import 'package:lab_manager/provider/entry_provider.dart';

class JournalWidget extends StatefulWidget {
  const JournalWidget({super.key});

  @override
  JournalWidgetState createState() => JournalWidgetState();
}

class JournalWidgetState extends State<JournalWidget> {
  @override
  void initState() {
    super.initState();
    Provider.of<EntryProvider>(context, listen: false).loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    return Scaffold(
      body: entryProvider.entries.isEmpty
          ? Center(child: Text("No entries found"))
          : ListView.builder(
        itemCount: entryProvider.entries.length,
        itemBuilder: (context, index) {
          final entry = entryProvider.entries[index];
          return buildEntry(entry, index);
        },
      ),
    );
  }

  Widget buildEntry(Entry entry, int index) => Dismissible(
    key: Key(entry.documentId!),
    background: Container(
      color: Colors.red,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 16.0),
      child: Icon(Icons.delete, color: Colors.white),
    ),
    secondaryBackground: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 16.0),
      child: Icon(Icons.delete, color: Colors.white),
    ),
    child: ListTile(
      leading: SizedBox(
        height: 50, // Constrain the height of the leading widget
        child: FittedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                DateFormat.d().format(entry.date),
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              Text(DateFormat.MMM().format(entry.date), style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
      title: Text(entry.title,
        style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(entry.description, 
        maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: () => Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => EntryEditingPage(entry: entry),
        ),
      ),
    ),
    onDismissed: (direction) async{
      try{
        await FirebaseFirestore.instance.collection("entries").doc(entry
          .documentId).delete();
      } catch (e) {
        print('Error deleting entry: $e');
      } finally{
        Provider.of<EntryProvider>(context, listen: false).loadEntries();
      }
    },
  );
}