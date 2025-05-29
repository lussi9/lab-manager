import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lab_manager/inventory/folder.dart';
import 'package:provider/provider.dart';
import 'package:lab_manager/inventory/inventory_provider.dart';
import 'package:lab_manager/inventory/fungibles_page.dart';
import 'package:lab_manager/objects/add_item_button.dart';

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
    final folders = Provider.of<InventoryProvider>(context).folders;
    return Column(
      children: [
        Expanded(
          child: folders.isEmpty
            ? ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index){
                  return AddItem(onPressed: () => _showAddFolderDialog(context));
              } )
            : ListView.builder(
              itemCount: folders.length + 1 ,
              itemBuilder: (context, index) {
                if (index == folders.length) { // Add Item button as the last item
                  return AddItem(onPressed: () => _showAddFolderDialog(context));
                }
                final folder = folders[index];
                return Slidable(
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        label: 'Delete',
                        onPressed: (context) {
                          Provider.of<InventoryProvider>(context, listen: false).deleteFolder(folder);
                        },
                      ),
                    ],),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        backgroundColor: Colors.blue,
                        icon: Icons.edit,
                        label: 'Edit',
                        onPressed: (context) {
                          _showAddFolderDialog(context, folder: folder);
                        },
                      ),
                    ],
                  ),
                  child: _buildFolderTile(folder),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFolderTile(Folder folder) => Card(
    child: ListTile(
      leading: const Icon(Icons.folder, size: 40),
      title: Text(
        folder.name,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FungiblesPage(folder: folder),
          ),
        );
      },
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    ),
  );

  void _showAddFolderDialog(BuildContext context, {Folder? folder}) {
    final _formKey = GlobalKey<FormState>();
    String folderName = folder?.name ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(folder == null ? 'Add New Folder' : 'Edit Folder'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            initialValue: folderName,
            autofocus: true,
            cursorColor: const Color.fromARGB(255, 204, 202, 202),
            decoration: const InputDecoration(
              labelText: 'Folder name',
              labelStyle: TextStyle(color: Colors.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a folder name';
              }
              return null;
            },
            onChanged: (value) => folderName = value,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(67, 160, 71, 1),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final provider = Provider.of<InventoryProvider>(context, listen: false);
                if (folder == null) {
                  provider.addFolder(Folder(name: folderName));
                } else {
                  provider.updateFolder(folder, folderName); // You need to implement this method
                }
                Navigator.pop(context);
              }
            },
            child: Text(folder == null ? 'Save' : 'Update', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
