import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lab_manager/objects/notification.dart';
import 'package:lab_manager/page/entry_editing_page.dart';
import 'package:lab_manager/provider/entry_provider.dart';
import 'package:lab_manager/provider/timer_provider.dart';
import 'package:lab_manager/provider/inventory_provider.dart';
import 'package:lab_manager/widget/calculations_widget.dart';
import 'widget/calendar_widget.dart';
import 'page/event_editing_page.dart';
import 'package:provider/provider.dart';
import 'provider/event_provider.dart';
import 'widget/journal_widget.dart';
import 'widget/inventory_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:lab_manager/page/account_page.dart';
import 'package:lab_manager/login/login_screen.dart';
import 'package:lab_manager/register/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationService().initNotification(); // Initialize the notification service

  final eventProvider = EventProvider();
  final entryProvider = EntryProvider();
  final timerProvider = TimerProvider();
  final inventoryProvider = InventoryProvider();

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
        ChangeNotifierProvider(create: (_) => timerProvider),
        ChangeNotifierProvider(create: (_) => inventoryProvider),
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
          primaryColor: Colors.green,
        ),
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
      IconButton(
        icon: Icon(Icons.person), // User icon
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AccountPage(), // Navigate to AccountPage
            ),
          );
        },
      ),
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


class AuthUserPage extends StatefulWidget {
  const AuthUserPage({super.key});

  @override
  State<AuthUserPage> createState() => _AuthUserPageState();
}

class _AuthUserPageState extends State<AuthUserPage> {
  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed:  () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(), // Navigate to login screen
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              minimumSize: const Size(180, 60),
            ),
            child: const Text('Sign in', style: TextStyle(fontSize: 22, color: Colors.white),),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RegisterScreen(), // Navigate to login screen
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              minimumSize: const Size(180, 60),
            ),
            child: const Text('Register', style: TextStyle(fontSize: 22, color: Colors.white)),
          ),
        ],
      ),
      ),
    );
  }
}