import 'package:flutter/material.dart';
import 'package:amora/core/theme/theme.dart';

import '../../../authentication/presentation/screens/home_screen.dart';
import 'memories_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'write_screen.dart';

class MainScreen extends StatefulWidget {
  final String initialEmail;

  const MainScreen({super.key, required this.initialEmail});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(email: widget.initialEmail),
      ProfileScreen(email: widget.initialEmail),
      const WriteScreen(),
      MemoriesScreen(email: widget.initialEmail),
      SettingsScreen(email: widget.initialEmail),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24 * fontScaleFactor),
            label: 'Home', // or 'ہوم' for Urdu
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24 * fontScaleFactor),
            label: 'Profile', // or 'پروفائل'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit, size: 24 * fontScaleFactor),
            label: 'Write', // or 'لکھیں'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, size: 24 * fontScaleFactor),
            label: 'Memories', // or 'یادیں'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 24 * fontScaleFactor),
            label: 'Settings', // or 'ترتیبات'
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.roseGold,
        unselectedItemColor: AppTheme.deepRose.withValues(alpha: 0.6),
        backgroundColor: AppTheme.creamWhite,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12 * fontScaleFactor,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12 * fontScaleFactor,
        ),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}