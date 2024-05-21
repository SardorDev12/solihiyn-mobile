import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_notifier.dart';
import 'zikr_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: Text("Solihiyn Zikrs", style: TextStyle(fontSize: 16))),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider<ThemeNotifier>(
            create: (_) => ThemeNotifier()..loadFromPrefs(),
            child: Consumer<ThemeNotifier>(
              builder: (context, theme, child) {
                return MaterialApp(
                  title: 'Flutter',
                  theme: theme.getTheme(),
                  home: const ZikrList(),
                );
              },
            ),
          );
        } else {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error loading preferences')),
            ),
          );
        }
      },
    );
  }
}
