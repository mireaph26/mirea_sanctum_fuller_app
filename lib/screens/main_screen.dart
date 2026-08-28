import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'landing_screen.dart';
import 'dashboard_screen.dart';
import 'finance_screen.dart';
import 'home_screen.dart';
import 'family_screen.dart';
import 'lifestyle_screen.dart';
import 'account_screen.dart';
import 'personal_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _screens = const [
    DashboardScreen(),
    FinanceScreen(),
    HomeScreen(),
    FamilyScreen(),
    LifestyleScreen(),
    PersonalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Account',
          padding: const EdgeInsets.all(8),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AccountScreen()),
          ),
          icon: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('assets/logo.png', width: 32, height: 32),
          ),
        ),
        title: Text('Mirea Sanctum',
            style: GoogleFonts.dancingScript(
                fontSize: 20, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LandingScreen()));
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), label: 'Finance'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Family'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Lifestyle'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Personal'),
        ],
      ),
    );
  }
}
