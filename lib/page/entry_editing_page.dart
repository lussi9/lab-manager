import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab_manager/model/entry.dart';
import 'package:provider/provider.dart';

import '../provider/entry_provider.dart';

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
  final descriptionController = TextEditingController();
  late DateTime fromDate;

  @override
  void initState() {
    super.initState();
    fromDate = DateTime.now();
    fromDate = widget.entry?.date ?? DateTime.now();
    descriptionController.text = widget.entry?.description ?? '';
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const CloseButton(),
      actions: buildEditingActions(),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildDate(),
            const SizedBox(height: 12),
            buildDescription(),
          ],
        ),
      ),
    ),
  );

  List<Widget> buildEditingActions() => [
    ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      onPressed: saveEntry,
      icon: const Icon(Icons.done),
      label: const Text('SAVE'),
    ),
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
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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

  Widget buildDescription() => TextFormField(
    style: TextStyle(color: Colors.white),
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Add Description',
      hintStyle: TextStyle(color: Colors.grey),
    ),
    controller: descriptionController,
    validator: (value) => value != null && value.isEmpty
        ? 'The description cannot be empty'
        : null,
    maxLines: 5,
  );

  Future saveEntry() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      final entryProvider = Provider.of<EntryProvider>(context, listen: false);
      final entry = Entry(
        date: fromDate,
        description: descriptionController.text,
      );
      // Save to Firestore
      try {
        if (widget.entry == null) {
          entryProvider.addEntry(entry);
        } else {
          final entryUpdate = Entry(
            documentId: widget.entry!.documentId,
            date: fromDate,
            description: descriptionController.text,
          );
          entryProvider.editEntry(widget.entry!, entryUpdate);
        }
        Navigator.of(context).pop();
      } catch (e) {
        print("Error saving entry: $e");
      }
    }
  }
}