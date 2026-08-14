import 'package:flutter/material.dart';

import '../../app/app_controller.dart';

class FollowedItemsView extends StatelessWidget {
  const FollowedItemsView({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.followedItems.toList()
      ..sort((a, b) => a.type.index.compareTo(b.type.index));
    if (items.isEmpty) {
      return const Center(child: Text('No followed items yet'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(item.type.name[0].toUpperCase())),
            title: Text(item.label),
            subtitle: Text([
              item.type.name.toUpperCase(),
              item.subtitle,
            ].whereType<String>().join(' · ')),
            trailing: IconButton(
              tooltip: 'Remove followed item',
              onPressed: () => controller.toggleFollowed(item),
              icon: const Icon(Icons.bookmark),
            ),
          ),
        );
      },
    );
  }
}
