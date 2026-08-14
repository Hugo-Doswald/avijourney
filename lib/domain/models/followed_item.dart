enum FollowedItemType { aircraft, flight, airline, route, airport }

class FollowedItem {
  const FollowedItem({
    required this.type,
    required this.identifier,
    required this.label,
    this.subtitle,
  });

  final FollowedItemType type;
  final String identifier;
  final String label;
  final String? subtitle;

  String get storageValue =>
      '${type.name}|${Uri.encodeComponent(identifier)}|${Uri.encodeComponent(label)}|${Uri.encodeComponent(subtitle ?? '')}';

  static FollowedItem? fromStorageValue(String value) {
    final parts = value.split('|');
    if (parts.length != 4) return null;
    final type = FollowedItemType.values
        .where((candidate) => candidate.name == parts[0])
        .firstOrNull;
    if (type == null) return null;
    return FollowedItem(
      type: type,
      identifier: Uri.decodeComponent(parts[1]),
      label: Uri.decodeComponent(parts[2]),
      subtitle: Uri.decodeComponent(parts[3]).isEmpty
          ? null
          : Uri.decodeComponent(parts[3]),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FollowedItem &&
      other.type == type &&
      other.identifier.toUpperCase() == identifier.toUpperCase();

  @override
  int get hashCode => Object.hash(type, identifier.toUpperCase());
}
