//import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _searchController = TextEditingController();
  List<Entry> _filteredEntries = [];

  @override
  void initState() {
    super.initState();
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    entryProvider.loadEntries();
    _filteredEntries = entryProvider.entries;
  }

  void _filterEntries(String query) {
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    setState(() {
      if (query.isEmpty) {
        _filteredEntries = entryProvider.entries; // Show all entries if query is empty
      } else {
        _filteredEntries = entryProvider.entries
            .where((entry) =>
                entry.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            onChanged: _filterEntries, // Call _filterEntries on text change
            cursorColor: Colors.green[800],
            decoration: InputDecoration(
              hintText: 'Search entries by title...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.green[800]!, // Set the border color to green when focused
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
        // Entry list
        Expanded(
          child: _filteredEntries.isEmpty
              ? const Center(child: Text("No entries found"))
              : ListView.builder(
                  itemCount: _filteredEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _filteredEntries[index];
                    return buildEntry(entry, index);
                  },
                ),
        ),
      ],
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
        Provider.of<EntryProvider>(context, listen: false).deleteEntry(entry);
      } catch (e) {
        print('Error deleting entry: $e');
      } finally{
        Provider.of<EntryProvider>(context, listen: false).loadEntries();
      }
    },
  );
}