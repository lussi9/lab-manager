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

  @override
  void initState() {
    super.initState();
    Provider.of<EntryProvider>(context, listen: false).loadEntries();
  }

  void _filterEntries(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Filters the list of entries based on the search query.
  List<Entry> getFilteredEntries(List<Entry> entries) {
    if (_searchQuery.isEmpty) return entries;
    return entries
        .where((entry) =>
            entry.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
Widget build(BuildContext context) {
  final entries = Provider.of<EntryProvider>(context).entries;
  final filteredEntries = getFilteredEntries(entries);

  return Scaffold(
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            onChanged: _filterEntries,
            decoration: const InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("The entry: ${entry.title} was deleted")),
                            );
                            Provider.of<EntryProvider>(context, listen: false)
                                .deleteEntry(entry);
                            Provider.of<EntryProvider>(context, listen: false)
                                .loadEntries();
                          },
                        ),
                      ],
                    ),
                    child: buildEntry(entry),
                  );
                },
              ),
        ),
      ],
    ),
  );
}

  Widget buildEntry(Entry entry) => Card(
    child: ListTile(
      leading: SizedBox(
        height: 50,
        child: FittedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                DateFormat.d().format(entry.date),
                style: const TextStyle(color: Color(0xff9fe594), fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(DateFormat.MMM().format(entry.date),
                style: TextStyle( color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
      ),
      title: Text(entry.title, style: Theme.of(context).textTheme.titleMedium,),
      subtitle: Text(
        entry.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white)
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EntryEditingPage(entry: entry),
        ),
      ),
    ),
  );
}
