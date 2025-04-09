import 'package:flutter/material.dart';
import 'package:lab_manager/model/fungible.dart';

class InventoryWidget extends StatefulWidget {
  @override
  _InventoryWidgetState createState() => _InventoryWidgetState();
}

class _InventoryWidgetState extends State<InventoryWidget> with AutomaticKeepAliveClientMixin{
  List<Fungible> fungibles = [];
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true; // Keep the state of this widget alive

  @override
  void initState(){
    super.initState();
    loadFungibles();
  }

  Future<void> loadFungibles() async {
    try {
      List<Fungible> data = await Fungible.fetchFungibles();
      setState(() {
        fungibles = data;
        isLoading = false;
      });
    } catch (e) {
      // Handle errors (e.g., display an error message)
      print('Error fetching fungibles: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super.build to ensure the state is kept alive

    return isLoading? Center(child: CircularProgressIndicator(),) : ListView.separated(
      itemCount: fungibles.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(fungibles[index].name, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
          subtitle: Text(fungibles[index].description, style: TextStyle(color: Colors.white)),
          trailing: Text(fungibles[index].quantity.toString(),
              style: TextStyle(fontSize: 20,
                  color: fungibles[index].quantity > 1 ? Colors.green : Colors
                      .red)),
        );
      },
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey[700],
        thickness: 1,
        indent: 16,
        endIndent: 16,
      ),
    );
  }
}
