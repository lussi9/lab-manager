import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lab_manager/account/account_page.dart';
import 'package:lab_manager/calculations/calculations_provider.dart';
import 'package:lab_manager/calendar/event.dart';
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
import 'package:google_fonts/google_fonts.dart';

final ThemeData labManagerTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFF005a4e),
  scaffoldBackgroundColor: Color(0xFFF2F2F2),

  textTheme: GoogleFonts.poppinsTextTheme().copyWith(
    titleLarge: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Color(0xFFF2F2F2),
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF2F2F2),
    ),
    bodyMedium: GoogleFonts.poppins(
      color: Color(0xFFF2F2F2),
    ),
  ),

  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF005a4e),
    primary: Color(0xFF005a4e),
    secondary: Color(0xff9fe594),
    background: Color(0xFFF2F2F2),
    surface: Color(0xFFF2F2F2),
    onPrimary: Color(0xFFF2F2F2),
    onSecondary: Color(0xFF005a4e),
    onBackground: Colors.black,
    onSurface: Colors.black,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xff9fe594),
    elevation: 2,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Color(0xff005a4e),
    ),
    iconTheme: IconThemeData(
      color: Color(0xff005a4e),
      size: 30,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF005a4e),
      foregroundColor: Color(0xFFF2F2F2),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 1,
      minimumSize: Size(150, 60),
      textStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Color(0xFF005a4e),
    ),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF005a4e),
    foregroundColor: Color(0xFFF2F2F2),
    iconSize: 34,
    elevation: 6,
  ),

  cardTheme: CardTheme(
    color: Color(0xFF005a4e),
    margin: EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),

  iconTheme: IconThemeData(
    color: Color(0xFF005a4e),
    size: 30,
  ),

  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF005a4e), width: 2),
    ),
    labelStyle: TextStyle(color: Color(0xFF005a4e)),
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: Color(0xFF005a4e),
    contentTextStyle: TextStyle(color: Color(0xFFF2F2F2)),
    behavior: SnackBarBehavior.floating,
  ),

  dividerColor: Color.fromARGB(255, 143, 143, 143),
);

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
  final calculationsProvider = CalculationsProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => eventProvider),
        StreamProvider<List<Event>>(
          create: (context) => context.read<EventProvider>().eventStream,
          initialData: const [],
        ),
        ChangeNotifierProvider(create: (_) => entryProvider),
        ChangeNotifierProvider(create: (_) => inventoryProvider),
        ChangeNotifierProvider(create: (_) => timerProvider),
        ChangeNotifierProvider(create: (_) => calculationsProvider),
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
        theme: labManagerTheme,

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
        //centerTitle: true,
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
      body: Column(
        children: [
          Expanded(
            child:TabBarView(
              controller: _tabController,
              children: [
                JournalWidget(),
                CalendarWidget(),
                CalculationsWidget(),
                InventoryWidget(), 
              ],
            ),
          ),
          Divider(color: Color.fromARGB(255, 94, 94, 94), height: 0.5, thickness: 0.3,),
        ]
      ),
      bottomNavigationBar: Material(
        color: Color(0xFFF2F2F2),
        child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(
                icon: Icon(_selectedTabIndex == 0 ? Icons.text_snippet : Icons.text_snippet_outlined, size: 32),
                child: Text('Journal',style: TextStyle(fontSize: 11)),
              ),
              Tab(
                icon: Icon(_selectedTabIndex == 1 ? Icons.calendar_month : Icons.calendar_month_outlined, size: 32),
                child: Text('Calendar',style: TextStyle(fontSize: 11)),
              ),
              Tab(
                icon: Icon(_selectedTabIndex == 2 ? Icons.calculate : Icons.calculate_outlined, size: 32),
                child: Text('Calculations', style: TextStyle(fontSize: 11)),
              ),
              Tab(
                icon: _selectedTabIndex == 3
                    ? Image.asset('assets/lab_panel_verde.png', height: 32)
                    : Image.asset('assets/lab_panel_gris.png', height: 32),
                child: Text('Inventory', style: TextStyle(fontSize: 11),
                ),
              ),
            ],
            unselectedLabelColor: Color.fromARGB(255, 94, 94, 94),
          ),
        ),
      floatingActionButton: _buildFloatingActionButton(),
  );

  Widget? _buildFloatingActionButton() {
    if (_selectedTabIndex == 0) { //Journal tab
      return FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EntryEditingPage(entry: null), // Pass appropriate arguments
          ),
        ),
        child: Icon(Icons.add),
      );
    } else if (_selectedTabIndex == 1) { //Calendar tab
      return FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventEditingPage(), // Navigate to EventEditingPage
          ),
        ),
        child: Icon(Icons.add),
      );
    } else {
      return null;
    }
  }

}
