import 'package:flutter/material.dart';
import 'package:lab_manager/model/fungible.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:lab_manager/provider/inventory_provider.dart';
import 'package:lab_manager/page/new_item_form.dart';

class InventoryWidget extends StatefulWidget {
  const InventoryWidget({super.key});

  @override
  InventoryWidgetState createState() => InventoryWidgetState();
}

class InventoryWidgetState extends State<InventoryWidget> {
  @override
  void initState(){
    super.initState();
    Provider.of<InventoryProvider>(context, listen: false).loadFungibles();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          if (inventoryProvider.fungibles.isEmpty)
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
                      child: AddNewItemForm(), // Custom widget for the form
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800], // Green background
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                child: Text(
                  "Add New Item",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          if (inventoryProvider.fungibles.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  "No fungibles found",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ),
          if (inventoryProvider.fungibles.isNotEmpty)
            Expanded(
              child: ListView.separated(
                itemCount: inventoryProvider.fungibles.length,
                itemBuilder: (context, index) {
                  final fungible = inventoryProvider.fungibles[index];
                  return buildFungible(fungible, index);
                },
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[700],
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
              ),
            ),
          if (inventoryProvider.fungibles.isNotEmpty)
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
                      child: AddNewItemForm(),
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
                  "Add New Item",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildFungible(Fungible fungible, int index) => Dismissible(
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
            icon: Icon(Icons.minimize, color: Colors.grey),
            onPressed: () async {
              if (fungible.quantity > 0) {
                await FirebaseFirestore.instance.collection("fungibles")
                    .doc(fungible.documentId).update({'Cantidad': fungible.quantity - 1});
                Provider.of<InventoryProvider>(context, listen: false).loadFungibles();
              }
            },
          ),
          Text(
            fungible.quantity.toString(),
            style: TextStyle(
              fontSize: 20,
              color: fungible.quantity > 1 ? Colors.green : Colors.red,
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.grey),
            onPressed: () async {
              await FirebaseFirestore.instance.collection("fungibles")
                  .doc(fungible.documentId).update({'Cantidad': fungible.quantity + 1});
              Provider.of<InventoryProvider>(context, listen: false).loadFungibles();
            },
          ),
        ],
      ),
    ),
    onDismissed: (direction) async{
      try{
        await FirebaseFirestore.instance.collection("fungibles").doc(fungible
          .documentId).delete();
      } catch (e) {
        print('Error deleting entry: $e');
      } finally{
        Provider.of<InventoryProvider>(context, listen: false).loadFungibles();
      }
    },
  );
}
