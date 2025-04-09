import 'package:flutter/material.dart';
import 'package:lab_manager/page/entry_editing_page.dart';
import 'package:lab_manager/provider/entry_provider.dart';
import 'package:lab_manager/widget/calculations_widget.dart';
import 'widget/calendar_widget.dart';
import 'page/event_editing_page.dart';
import 'package:provider/provider.dart';
import 'provider/event_provider.dart';
import 'widget/journal_widget.dart';
import 'widget/inventory_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final eventProvider = EventProvider();
  final entryProvider = EntryProvider();

  // Load events and entries before the app starts
  await Future.wait([ //run them concurrently
    eventProvider.loadEvents(),
    entryProvider.loadEntries(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => eventProvider),
        ChangeNotifierProvider(create: (_) => entryProvider),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final String title = 'Lab Manager';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: Colors.green,
        ),
        home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin{
  int _selectedTabIndex = 1;
  late TabController _tabController;
  
  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: _selectedTabIndex);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selectedTabIndex = _tabController.index);
      }
    });
  } //Track the currently selected tab

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(MyApp.title),
      centerTitle: true,
    ),
    body: TabBarView(
      controller: _tabController,
      children: [
        JournalWidget(), // Replace with your Journal page widget
        CalendarWidget(), // Your existing Calendar widget
        CalculationsWidget(), // Replace with your Calculator page widget
        InventoryWidget(), // Replace with your Inventory page widget
      ],
    ),
    bottomNavigationBar: Material(
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color.fromARGB(255, 79, 245, 165),
          tabs: const [
            Tab(text: 'Journal', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Calendar', icon: Icon(Icons.event)),
            Tab(text: 'Calculator', icon: Icon(Icons.calculate)),
            Tab(text: 'Inventory', icon: Icon(Icons.table_chart)),
          ],
        ),
      ),
    floatingActionButton: _buildFloatingActionButton(),
  );

  Widget? _buildFloatingActionButton() {
    if (_selectedTabIndex == 0) { //Journal tab
      return FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 51, 123, 54),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EntryEditingPage(entry: null), // Pass appropriate arguments
          ),
        ),
        child: Icon(Icons.add, color: Colors.white),
      );
    } else if (_selectedTabIndex == 1) { //Calendar tab
      return FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 51, 123, 54),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventEditingPage(), // Navigate to EventEditingPage
          ),
        ),
        child: Icon(Icons.add, color: Colors.white),
      );
    } else {
      return null;
    }
  }

}
