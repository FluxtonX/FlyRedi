import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SearchableBottomSheet extends StatefulWidget {
  final String title;
  final String hintText;
  final List<Map<String, String>> items;
  final Function(Map<String, String>) onSelected;
  final bool isMultiSelect;
  final List<Map<String, String>>? initialSelectedItems;

  const SearchableBottomSheet({
    super.key,
    required this.title,
    required this.hintText,
    required this.items,
    required this.onSelected,
    this.isMultiSelect = false,
    this.initialSelectedItems,
  });

  @override
  State<SearchableBottomSheet> createState() => _SearchableBottomSheetState();
}

class _SearchableBottomSheetState extends State<SearchableBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredItems = [];
  List<Map<String, String>> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items);
    if (widget.initialSelectedItems != null) {
      _selectedItems = List.from(widget.initialSelectedItems!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = List.from(widget.items);
      });
    } else {
      setState(() {
        _filteredItems = widget.items.where((item) {
          final name = item['name']?.toLowerCase() ?? '';
          final code = item['code']?.toLowerCase() ?? '';
          final lowerQuery = query.toLowerCase();
          return name.contains(lowerQuery) || code.contains(lowerQuery);
        }).toList();
      });
    }
  }

  void _toggleSelection(Map<String, String> item) {
    if (widget.isMultiSelect) {
      setState(() {
        final existingIndex = _selectedItems.indexWhere((e) => e['code'] == item['code']);
        if (existingIndex >= 0) {
          _selectedItems.removeAt(existingIndex);
        } else {
          _selectedItems.add(item);
        }
      });
    } else {
      widget.onSelected(item);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, // Match app card color
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.isMultiSelect)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedItems);
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Search Field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface, // Slightly lighter for contrast
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterItems,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.white54),
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.white54),
                          onPressed: () {
                            _searchController.clear();
                            _filterItems('');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Divider
          Divider(color: Colors.white.withOpacity(0.1), height: 1),

          // List
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = widget.isMultiSelect
                          ? _selectedItems.any((e) => e['code'] == item['code'])
                          : false;

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 24),
                        title: Text(
                          item['name'] ?? '',
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: Text(
                          item['code'] ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12,
                          ),
                        ),
                        leading: widget.isMultiSelect
                            ? Icon(
                                isSelected ? Icons.check_circle : Icons.circle_outlined,
                                color: isSelected ? AppColors.primary : Colors.white54,
                              )
                            : null,
                        onTap: () => _toggleSelection(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
