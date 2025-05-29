import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lab_manager/account/account_page.dart';
import 'package:lab_manager/calendar/event.dart';
import 'package:lab_manager/inventory/folder.dart';
import 'package:lab_manager/journal/entry.dart';
import 'package:lab_manager/objects/notification.dart';
import 'package:lab_manager/journal/entry_editing_page.dart';
import 'package:lab_manager/journal/entry_provider.dart';
import 'package:lab_manager/calculations/timer_provider.dart';
import 'package:lab_manager/inventory/inventory_provider.dart';
import 'package:lab_manager/calculations/calculations_widget.dart';
import 'calendar/calendar_widget.dart';
import 'calendar/event_editing_page.dart';
import 'package:provider/provider.dart';
import 'calendar/event_provider.dart';
import 'journal/journal_widget.dart';
import 'inventory/inventory_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:lab_manager/account/auth_user_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationService().initNotification(); // Initialize the notification service

  final eventProvider = EventProvider();
  final entryProvider = EntryProvider();
  final inventoryProvider = InventoryProvider();
  final timerProvider = TimerProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => eventProvider),
        ChangeNotifierProvider(create: (_) => entryProvider),
        ChangeNotifierProvider(create: (_) => inventoryProvider),
        ChangeNotifierProvider(create: (_) => timerProvider),
        StreamProvider<List<Event>>(
          create: (context) => Provider.of<EventProvider>(context, listen: false).eventStream(),
          initialData: const [],
        ),
        StreamProvider<List<Entry>>(
          create: (context) => Provider.of<EntryProvider>(context, listen: false).entryStream(),
          initialData: const [],
        ),
        StreamProvider<List<Folder>>(
          create: (context) => Provider.of<InventoryProvider>(context, listen: false).folderStream(),
          initialData: const [],
        ),
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
    final user = FirebaseAuth.instance.currentUser;
    
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: Color.fromRGBO(67, 160, 71, 1),
        ),

        locale: const Locale('en', 'GB'), // Set locale to English (United Kingdom)
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'GB'), // English (United Kingdom)
        ],

        home: user != null? MainPage() : AuthUserPage(),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.person), // User icon
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AccountPage(), // Navigate to AccountPage
                  ),
                );
              },
            )
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          JournalWidget(),
          CalendarWidget(),
          CalculationsWidget(),
          InventoryWidget(), 
        ],
      ),
      bottomNavigationBar: Material(
        child: SizedBox(
          height: 86,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color.fromRGBO(67, 160, 71, 1),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(icon: Icon( _selectedTabIndex == 0 ? Icons.text_snippet : Icons.text_snippet_outlined,
                  size: 36)),
              Tab(icon: Icon(_selectedTabIndex == 1 ? Icons.calendar_month : Icons.calendar_month_outlined,
                size: 36)),
              Tab(icon: Icon(_selectedTabIndex == 2 ? Icons.calculate : Icons.calculate_outlined,
                size: 36)),
              Tab(icon: Icon(_selectedTabIndex == 3 ? Icons.inventory : Icons.inventory_2_outlined,
                size: 36)),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
  );

  Widget? _buildFloatingActionButton() {
    if (_selectedTabIndex == 0) { //Journal tab
      return FloatingActionButton(
        backgroundColor: const Color.fromRGBO(67, 160, 71, 1),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EntryEditingPage(entry: null), // Pass appropriate arguments
          ),
        ),
        child: Icon(Icons.add, color: Colors.white),
      );
    } else if (_selectedTabIndex == 1) { //Calendar tab
      return FloatingActionButton(
        backgroundColor: const Color.fromRGBO(67, 160, 71, 1),
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
