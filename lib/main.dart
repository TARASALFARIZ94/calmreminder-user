// main.dart (USER APP VERSION)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Import local files
import 'firebase_options.dart';
import 'auth/login_page.dart';
import 'pages/user/user_dashboard.dart'; // Pastikan class di file ini bernama DashboardPage
import 'core/mqtt/mqtt_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MqttService()..connect(),
        ),
      ],
      child: MaterialApp(
        title: 'Calm Reminder User', // Beri nama pembeda
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Poppins',
          useMaterial3: true,
          colorSchemeSeed: Colors.blue, // Opsional: bedakan warna tema dengan admin
        ),
        
        // Rute awal
        initialRoute: '/login',
        
        // Tabel Rute (Hanya yang relevan untuk User)
        routes: {
          '/login': (context) => const LoginPage(),
          '/user_dashboard': (context) => const DashboardPage(),
        },

        home: const LoginPage(),
      ),
    );
  }
}