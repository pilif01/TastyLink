import 'package:flutter/material.dart';
import 'package:tasty_link/models/shopping_item.dart';

class ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onTap;
  final ValueChanged<bool> onCheckChanged;
  final VoidCallback? onDelete;

  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onCheckChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: item.checked,
        onChanged: (value) => onCheckChanged(value ?? false),
      ),
      title: Text(
        item.name,
        style: TextStyle(
          decoration: item.checked ? TextDecoration.lineThrough : null,
          color: item.checked ? Colors.grey : null,
        ),
      ),
      subtitle: _buildSubtitle(),
      trailing: _buildTrailing(),
      onTap: onTap,
    );
  }

  Widget? _buildSubtitle() {
    final parts = <String>[];
    
    if (item.quantity != null && item.unit != null) {
      parts.add('${item.quantity} ${item.unit}');
    }
    
    if (item.category != null) {
      parts.add(item.category!);
    }
    
    if (parts.isEmpty) return null;
    
    return Text(parts.join(' • '));
  }

  Widget? _buildTrailing() {
    if (onDelete == null) return null;
    
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      onPressed: onDelete,
      tooltip: 'Delete item',
    );
  }
}
