import 'package:flutter/material.dart';
import 'package:lab_manager/model/folder.dart';
import 'package:lab_manager/model/fungible.dart';
import 'package:provider/provider.dart';
import 'package:lab_manager/provider/inventory_provider.dart';
import 'package:lab_manager/page/new_item_form.dart';

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
              icon: Icon(Icons.settings, color: Colors.grey[600]),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setModalState) {
                        final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Settings",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                title: const Text("Change quantity limit"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        if (inventoryProvider.quantityLimit > 0) {
                                          setModalState(() {
                                            inventoryProvider.setQuantityLimit(inventoryProvider.quantityLimit - 1);
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      inventoryProvider.quantityLimit.toString(),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setModalState(() {
                                          inventoryProvider.setQuantityLimit(inventoryProvider.quantityLimit + 1);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
          child: ListView.separated(
            itemCount: fungibleList.length,
            itemBuilder: (context, index) {
              return buildFungible(fungibleList[index], index);
            },
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey[700],
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
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
                child: AddNewItemForm(folderId: widget.folder.documentId!),
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
            "Add item",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    ],),);
  }

  Widget buildFungible(Fungible fungible, int index) { 
  final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

  return Dismissible(
    key: Key(fungible.documentId!),
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
              color: fungible.quantity >= inventoryProvider.quantityLimit ? Colors.green : Colors.red,
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
    onDismissed: (direction) async{
      try{
        Provider.of<InventoryProvider>(context, listen: false).deleteFungible(widget.folder.documentId!, fungible);
      } catch (e) {
        print('Error deleting entry: $e');
      }
    },
  );
  }
}
