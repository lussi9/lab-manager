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
    final folders = Provider.of<InventoryProvider>(context).folders;

    return Scaffold(
      body: Column(
      children: [
        Expanded(
          child: folders.isEmpty
            ? ListView.builder( // If no folders, show a message and an Add Item button
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
      ),
    );
  }

  Widget _buildFolderTile(Folder folder) => Card(
    child: ListTile(
      leading: Icon(Icons.folder, color: Color(0xfff2f2f2),),
      title: Text(
        folder.name, style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FungiblesPage(folder: folder),
          ),
        );
      },
      trailing: Icon(Icons.arrow_forward_ios, color: Color(0xfff2f2f2),),
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
            decoration: const InputDecoration(
              hintText: 'Folder name',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final provider = Provider.of<InventoryProvider>(context, listen: false);
                if (folder == null) {
                  provider.addFolder(Folder(name: folderName));
                } else {
                  provider.updateFolder(folder, folderName);
                }
                Navigator.pop(context);
              }
            },
            child: Text(folder == null ? 'Save' : 'Update'),
          ),
        ],
      ),
    );
  }
}
