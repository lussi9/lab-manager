import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lab_manager/inventory/folder.dart';
import 'package:lab_manager/inventory/fungible.dart';
import 'package:lab_manager/objects/add_item_button.dart';
import 'package:provider/provider.dart';
import 'package:lab_manager/inventory/inventory_provider.dart';

class FungiblesPage extends StatefulWidget {
  final Folder folder;

  const FungiblesPage({super.key, required this.folder});

  @override
  FungiblesPageState createState() => FungiblesPageState();
}

class FungiblesPageState extends State<FungiblesPage> {
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
                  value: inventoryProvider.selectedOrder,
                  onChanged: (value) {
                    setState(() {
                      Provider.of<InventoryProvider>(context, listen: false).setOrder(value!, widget.folder.documentId!);
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: "name",
                      child: Text("Order by Name", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    ),
                    DropdownMenuItem(
                      value: "quantity",
                      child: Text("Order by Quantity", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    ),
                  ],
                  hint: Text("Order List"),
                ),
                IconButton(
                  icon: Icon(Icons.settings, size: 30,),
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
                                          icon: Icon(Icons.remove),
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
                                          tempLimit.toString(), style: TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(Icons.add),
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
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    inventoryProvider.setQuantityLimit(tempLimit);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Save'),
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
          Expanded(
            child: fungibleList.isEmpty ? 
            ListView.builder(
              itemCount: 2,
              itemBuilder: (context, index){
                return AddItem(onPressed: () => _showAddFungibleDialog(context));
            })
            :
            ListView.builder(
              itemCount: fungibleList.length + 1,
              itemBuilder: (context, index) {
                if (index == fungibleList.length) { // Add Item button as the last item
                  return AddItem(onPressed: () => _showAddFungibleDialog(context));
                }
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
                          SnackBar(content: Text("The fungible: ${fungibleList[index].name} was deleted")),
                        );
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
            )
          ),
        ]
      )
    );
  }

  Widget buildFungible(Fungible fungible, int index) { 
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    return Card(
      child: Container(
        height: 70, // Set the minimum height for the ListTile
        child: Center(
          child: ListTile(
            title: Text(
              fungible.name, style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: fungible.description.isNotEmpty 
                ? Text(fungible.description, style: Theme.of(context).textTheme.bodyMedium) 
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.remove, color: Color(0xfff2f2f2)),
                  onPressed: () async {
                    if (fungible.quantity > 0) {
                      inventoryProvider.updateFungible(
                        widget.folder.documentId!,
                        Fungible(
                          documentId: fungible.documentId,
                          name: fungible.name,
                          description: fungible.description,
                          quantity: fungible.quantity - 1,
                        ),
                      );
                    }
                  },
                ),
                SizedBox(width: 8),
                Text(
                  fungible.quantity.toString(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: fungible.quantity >= inventoryProvider.quantityLimit 
                        ? Color(0xff9fe594) 
                        : Colors.red,
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.add, color: Color(0xfff2f2f2),),
                  onPressed: () async {
                    inventoryProvider.updateFungible(
                      widget.folder.documentId!,
                      Fungible(
                        documentId: fungible.documentId,
                        name: fungible.name,
                        description: fungible.description,
                        quantity: fungible.quantity + 1,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        )
      )
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
                decoration: const InputDecoration(
                  hintText: 'Name',
                ),
                onChanged: (value) => name = value,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(
                  hintText: 'Description',
                ),
                onChanged: (value) => description = value,
              ),
              TextFormField(
                initialValue: quantity.toString(),
                decoration: const InputDecoration(
                  hintText: 'Quantity',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
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
            child: Text(fungible == null ? 'Save' : 'Update'),
          ),
        ],
      ),
    );
  }
}
