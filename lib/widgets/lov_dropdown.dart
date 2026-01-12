import 'package:flutter/material.dart';
import '../models/lov_model.dart';

/// Widget reusable untuk dropdown LOV (List of Values)
class LovDropdown extends StatelessWidget {
  final String? label;
  final String? hint;
  final LovModel? value;
  final List<LovModel> items;
  final ValueChanged<LovModel?>? onChanged;
  final String? Function(LovModel?)? validator;
  final bool enabled;
  final IconData? prefixIcon;
  final bool showSearch; // Untuk dropdown dengan banyak item

  const LovDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.showSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<LovModel>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey.shade200 : null,
      ),
      items: items.map((LovModel item) {
        return DropdownMenuItem<LovModel>(
          value: item,
          child: Text(
            item.description,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
      hint: hint != null ? Text(hint!) : null,
      selectedItemBuilder: (BuildContext context) {
        return items.map<Widget>((LovModel item) {
          return Text(
            item.description,
            overflow: TextOverflow.ellipsis,
          );
        }).toList();
      },
    );
  }
}

/// Widget untuk LOV dengan search functionality (jika banyak item)
class LovDropdownWithSearch extends StatefulWidget {
  final String? label;
  final String? hint;
  final LovModel? value;
  final List<LovModel> items;
  final ValueChanged<LovModel?>? onChanged;
  final String? Function(LovModel?)? validator;
  final bool enabled;
  final IconData? prefixIcon;

  const LovDropdownWithSearch({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  State<LovDropdownWithSearch> createState() => _LovDropdownWithSearchState();
}

class _LovDropdownWithSearchState extends State<LovDropdownWithSearch> {
  List<LovModel> filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredItems = widget.items
          .where((item) =>
              item.description.toLowerCase().contains(query) ||
              item.code.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        InkWell(
          onTap: widget.enabled
              ? () => _showSearchDialog(context)
              : null,
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon)
                  : null,
              border: const OutlineInputBorder(),
              filled: !widget.enabled,
              fillColor: !widget.enabled ? Colors.grey.shade200 : null,
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            child: Text(
              widget.value?.description ?? widget.hint ?? '',
              style: TextStyle(
                color: widget.value == null
                    ? Colors.grey.shade600
                    : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    _searchController.clear();
    filteredItems = widget.items;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Cari',
                  hintText: 'Ketik untuk mencari...',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final isSelected = widget.value?.code == item.code;
                  return ListTile(
                    title: Text(item.description),
                    subtitle: item.code != item.description
                        ? Text(item.code)
                        : null,
                    selected: isSelected,
                    selectedTileColor: Colors.green.shade50,
                    onTap: () {
                      widget.onChanged?.call(item);
                      Navigator.pop(context);
                    },
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

