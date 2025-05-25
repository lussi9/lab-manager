import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lab_manager/inventory/folder.dart';
import 'package:lab_manager/inventory/fungible.dart';
import 'package:provider/provider.dart';
import 'package:lab_manager/inventory/inventory_provider.dart';

class FungiblesPage extends StatefulWidget {
  final Folder folder;

  const FungiblesPage({super.key, required this.folder});

  @override
  FungiblesPageState createState() => FungiblesPageState();
}

class FungiblesPageState extends State<FungiblesPage> {
  String _selectedOrder = "name";

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final fungibleList = inventoryProvider.getFungibles(widget.folder.documentId!);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
      ),
      body: Column(
        children: [
        Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<String>(
              value: _selectedOrder,
              onChanged: (value) {
                setState(() {
                  _selectedOrder = value!;
                  Provider.of<InventoryProvider>(context, listen: false).setOrder(value);
                  Provider.of<InventoryProvider>(context, listen: false).orderList(widget.folder.documentId!);
                });
              },
              items: [
                DropdownMenuItem(
                  value: "name",
                  child: Text("Order by Name"),
                ),
                DropdownMenuItem(
                  value: "quantity",
                  child: Text("Order by Quantity"),
                ),
              ],
              hint: Text("Order List"),
            ),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.grey[350]),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    int tempLimit = inventoryProvider.quantityLimit;
                    return StatefulBuilder(
                      builder: (context, setDialogState) {
                        return AlertDialog(
                          title: const Text("Settings"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text("Change quantity limit"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        if (tempLimit > 0) {
                                          setDialogState(() {
                                            tempLimit--;
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      tempLimit.toString(),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setDialogState(() {
                                          tempLimit++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                                inventoryProvider.setQuantityLimit(tempLimit);
                                Navigator.pop(context);
                              },
                              child: const Text('Save', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      if (inventoryProvider.folderFungibles[widget.folder.documentId]?.isNotEmpty ?? false)
        Expanded(
          child: ListView.builder(
            itemCount: fungibleList.length,
            itemBuilder: (context, index) {
              return Slidable( 
                startActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    backgroundColor: Colors.red,
                    icon: Icons.delete,
                    label: 'Delete',
                    onPressed: (context) {
                      Provider.of<InventoryProvider>(context, listen: false).deleteFungible(widget.folder.documentId!, fungibleList[index]);
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
                          _showAddFungibleDialog(context, fungible: fungibleList[index]);
                        },
                      ),
                    ],
                  ),
                child: buildFungible(fungibleList[index], index),
              );
            },
          ),
        ),
      Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            _showAddFungibleDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(67, 160, 71, 1),
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "Add item",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    ],),);
  }

  Widget buildFungible(Fungible fungible, int index) { 
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    return Card(
      child: ListTile(
        title: Text(fungible.name, 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
        subtitle: Text(fungible.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Ensures the Row takes minimal space
          children: [
            IconButton(
              icon: Icon(Icons.remove, color: Colors.grey),
              onPressed: () async {
                if (fungible.quantity > 0) {
                  inventoryProvider.updateFungible(widget.folder.documentId!, Fungible(
                    documentId: fungible.documentId,
                    name: fungible.name,
                    description: fungible.description,
                    quantity: fungible.quantity - 1,
                  ));
                }
              },
            ),
            SizedBox(width: 8),
            Text(
              fungible.quantity.toString(),
              style: TextStyle(
                fontSize: 20,
                color: fungible.quantity >= inventoryProvider.quantityLimit ? Color.fromRGBO(67, 160, 71, 1) : Colors.red,
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.add, color: Colors.grey),
              onPressed: () async {
                inventoryProvider.updateFungible(widget.folder.documentId!, Fungible(
                  documentId: fungible.documentId,
                    name: fungible.name,
                    description: fungible.description,
                    quantity: fungible.quantity + 1,));
              }, 
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFungibleDialog(BuildContext context, {Fungible? fungible}) {
    final _formKey = GlobalKey<FormState>();
    String name = fungible?.name ?? '';
    String description = fungible?.description ?? '';
    int quantity = fungible?.quantity ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(fungible == null ? 'Add New Item' : 'Edit Item'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                cursorColor: Colors.grey[350],
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                onChanged: (value) => name = value,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                initialValue: description,
                cursorColor: Colors.grey[350],
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                onChanged: (value) => description = value,
              ),
              TextFormField(
                initialValue: quantity.toString(),
                cursorColor: Colors.grey[350],
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  quantity = parsed != null && parsed >= 0 ? parsed : 0;
                },
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid number ≥ 0';
                  }
                  return null;
                },
              ),
            ],
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
                if (fungible == null) {
                  provider.addFungible(widget.folder.documentId!, Fungible(name: name, description: description, quantity: quantity));
                } else {
                  provider.updateFungible(
                    widget.folder.documentId!,
                    Fungible(
                      documentId: fungible.documentId,
                      name: name,
                      description: description,
                      quantity: quantity,
                    ),
                  );
                }
                Navigator.pop(context);
              }
            },
            child: Text(fungible == null ? 'Save' : 'Update', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
