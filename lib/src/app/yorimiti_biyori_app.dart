import 'package:flutter/material.dart';

import '../pages/history_page.dart';
import '../pages/settings_page.dart';
import '../pages/suggestion_page.dart';

class YorimitiBiyoriApp extends StatelessWidget {
  const YorimitiBiyoriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'よりみち日和',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // UI プロトタイプのグリーン基調（primary #3F6F44）に合わせる。
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F6F44)),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}

/// UI プロトタイプどおりの 3 タブ構成。ホーム画面は持たず、提案タブをトップにする。
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    SuggestionPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            selectedIcon: Icon(Icons.lightbulb),
            label: '提案',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: '履歴',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
