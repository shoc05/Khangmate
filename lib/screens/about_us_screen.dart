import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_bottom_nav.dart';
import '../routes.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  int _navIndex = 4;

  void _onNav(int idx) {
    if (idx == 0) { Navigator.pushNamed(context, Routes.home); return; }
    if (idx == 1) { Navigator.pushNamed(context, Routes.map); return; }
    if (idx == 2) { 
      Navigator.pushNamed(context, Routes.chatHome); 
      return; 
    }
    if (idx == 3) { Navigator.pushNamed(context, Routes.chatHome); return; }
    if (idx == 4) return;
    setState(() => _navIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Row(children: [AppLogo(size: 28), SizedBox(width: 8), Text('About Us')])),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'KhangMate is an exclusive app for finding rental homes in Bhutan. '
          'Browse listings, chat with landlords, and manage bookings all in one place. '
          'Built with love for local users.',
          style: TextStyle(fontSize: 16),
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: _navIndex, onTap: _onNav),
    );
  }
}
