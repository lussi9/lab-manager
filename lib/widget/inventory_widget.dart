import 'package:flutter/material.dart';
import 'package:lab_manager/model/folder.dart';
import 'package:provider/provider.dart';
import 'package:lab_manager/provider/inventory_provider.dart';
import 'package:lab_manager/page/new_item_form.dart';
import 'package:lab_manager/page/fungibles_page.dart';

class InventoryWidget extends StatefulWidget {
  const InventoryWidget({super.key});

  @override
  InventoryWidgetState createState() => InventoryWidgetState();
}

class InventoryWidgetState extends State<InventoryWidget> {

  @override
  void initState(){
    super.initState();
    Provider.of<InventoryProvider>(context, listen: false).loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildFolders(),
    );
  }

  Widget buildFolders() {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    return Column(
      children: [
        Expanded(
          child: inventoryProvider.folders.isEmpty
            ? const Center(child: Text("No folders found"))
            : ListView.builder(
                itemCount: inventoryProvider.folders.length,
                itemBuilder: (context, index) {
                  final folder = inventoryProvider.folders[index];
                  return _buildFolderTile(folder);
                },
              ),
          ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: AddNewItemForm(folderId: ""),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Add folder",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFolderTile(Folder folder) {
    return Dismissible(
      key: Key(folder.documentId!),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) async {
        try{
          await Provider.of<InventoryProvider>(context, listen: false).deleteFolder(folder);
        } catch (e) {
          print('Error deleting folder: $e');
        }
      },
      child: ListTile(
        title: Text(
          folder.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FungiblesPage(folder: folder),
            ),
          );
        },
      ),
    );
  }
}
