import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab_manager/journal/entry.dart';
import 'package:provider/provider.dart';
import 'package:lab_manager/journal/entry_provider.dart';

class EntryEditingPage extends StatefulWidget {
  final Entry? entry; // Optional existing entry

    const EntryEditingPage({
    Key? key,
    this.entry,
  }) : super(key: key);

  @override
  State<EntryEditingPage> createState() => _EntryEditingPageState();
}

class _EntryEditingPageState extends State<EntryEditingPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  late DateTime fromDate;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.entry?.title ?? '';
    fromDate = DateTime.now();
    fromDate = widget.entry?.date ?? DateTime.now();
    descriptionController.text = widget.entry?.description ?? '';
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const CloseButton(),
      actions: buildEditingActions(),
      backgroundColor: Color.fromRGBO(67, 160, 71, 1),
    ),
    body: Container(
      padding: const EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          children: <Widget>[
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              title: TextFormField(
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                cursorColor: Color.fromRGBO(67, 160, 71, 1),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add Title',
                ),
                validator: (title) =>
                  title != null && title.isEmpty ? 'Title cannot be empty' : null,
                controller: titleController,
              ),
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
                ),
                controller: descriptionController,
                validator: (value) => value != null && value.isEmpty
                ? 'The description cannot be empty' : null,
              )
            ),
            ListTile( // Date
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: Icon(
                Icons.date_range,
                color: Colors.grey),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(fromDate),
                        textAlign: TextAlign.left,
                      ),
                      onTap: () async {
                        pickFromDateTime(pickDate: true);
                      })),
            ])),
          ],
        ),
      ),
    ),
  );

  List<Widget> buildEditingActions() => [
    IconButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconColor: Colors.white,
        iconSize: 22,
      ),
      onPressed: saveEntry,
      icon: Icon(Icons.done),
    ),
    SizedBox(width: 12),
  ];

  Widget buildDate() => SizedBox(
    width: 150,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      onPressed: () => pickFromDateTime(pickDate: true),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.date_range),
          SizedBox(width: 8),
          Text(DateFormat('dd/MM/yyyy').format(fromDate)),
        ],
      ),
    ),
  );

  Future pickFromDateTime({required bool pickDate}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );

    if (date == null) return;

    if (mounted) {
      setState(() {
        fromDate = DateTime(
          date.year,
          date.month,
          date.day,
        );
      });
    }
  }

  Future saveEntry() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      final entryProvider = Provider.of<EntryProvider>(context, listen: false);
      final entry = Entry(
        title: titleController.text,
        date: fromDate,
        description: descriptionController.text,
      );
      // Save to Firestore
      if (widget.entry == null) {
        entryProvider.addEntry(entry);
      } else {
        final entryUpdate = Entry(
          documentId: widget.entry!.documentId,
          title: titleController.text,
          date: fromDate,
          description: descriptionController.text,
        );
        entryProvider.editEntry(widget.entry!, entryUpdate);
      }
      Navigator.of(context).pop();
    }
  }
}
