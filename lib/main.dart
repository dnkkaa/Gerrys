// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:gown_rental/homepage.dart';
import 'package:gown_rental/Admin/dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:gown_rental/pages/start.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wrodrayxzsywrzbnuswd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indyb2RyYXl4enN5d3J6Ym51c3dkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjI0MzUzOTgsImV4cCI6MjAzODAxMTM5OH0.zSTdlKKIV-yv7R2iDvOStneD1UbtXjqSemofoFevWcE',
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
         ChangeNotifierProvider(create: (_) => NotificationsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return FutureBuilder(
            future: _getInitialScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              } else {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  themeMode: themeProvider.currentTheme,
                  theme: ThemeData.light(),
                  darkTheme: ThemeData.dark(),
                  home: snapshot.data as Widget,
                );
              }
            },
          );
        },
      ),
    );
  }

  Future<Widget> _getInitialScreen() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && session.user != null) {
      if (session.user!.email == 'gownrental3@gmail.com') {
        return const AdminPage();
      } else {
        return const HomePage();
      }
    } else {
      return const GetStartedPage();
    }
  }
}
