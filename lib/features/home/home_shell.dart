import 'package:flutter/material.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = <String>['Radar', 'Map', 'Cards', 'Saved'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AviJourney'),
            Text('V0.3.0 · Flutter foundation', style: TextStyle(fontSize: 11)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Text('FOUNDATION')),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            _titles[_index],
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.radar), label: 'Radar'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.view_agenda_outlined), label: 'Cards'),
          NavigationDestination(icon: Icon(Icons.bookmark_border), label: 'Saved'),
        ],
      ),
    );
  }
}
