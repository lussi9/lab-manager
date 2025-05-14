//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'entry.dart';
import 'entry_editing_page.dart';
import 'package:lab_manager/journal/entry_provider.dart';

class JournalWidget extends StatefulWidget {
  const JournalWidget({super.key});

  @override
  JournalWidgetState createState() => JournalWidgetState();
}

class JournalWidgetState extends State<JournalWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _filterEntries(String query) {
    setState(() {
      _searchQuery = query; // Update the search query
    });
  }

  @override
  void initState() {
    super.initState();
    Provider.of<EntryProvider>(context, listen: false).loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    final entries = entryProvider.entries;
    // Filter entries based on the search query
    final filteredEntries = _searchQuery.isEmpty
        ? entries
        : entries
            .where((entry) =>
                entry.title.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      body: Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            onChanged: _filterEntries, // Call _filterEntries on text change
            cursorColor: Color.fromRGBO(67, 160, 71, 1),
            decoration: InputDecoration(
              hintText: 'Search entries by title...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Color.fromRGBO(67, 160, 71, 1), // Set the border color to green when focused
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
        // Entry list
        Expanded(
          child: filteredEntries.isEmpty
            ? const Center(child: Text("No entries found"))
            : ListView.builder(
              itemCount: filteredEntries.length,
              itemBuilder: (context, index) {
                final entry = filteredEntries[index];
                return Slidable(
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        label: 'Delete',
                        onPressed: (context) {
                          Provider.of<EntryProvider>(context, listen: false).deleteEntry(entry);
                        },
                      ),
                    ],),
                  child: buildEntry(entry, index)
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEntry(Entry entry, int index) => ListTile(
    leading: SizedBox(
      height: 50, // Constrain the height of the leading widget
      child: FittedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              DateFormat.d().format(entry.date),
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(67, 160, 71, 1)),
            ),
            Text(DateFormat.MMM().format(entry.date),
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    ),
    title: Text(entry.title,
        style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(entry.description,
        maxLines: 2, overflow: TextOverflow.ellipsis),
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryEditingPage(entry: entry),
      ),
    ),
  );
}