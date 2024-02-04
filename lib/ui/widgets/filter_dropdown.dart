// filter_dropdown.dart

import 'package:flutter/material.dart';

class FilterDropdown extends StatefulWidget {
  final List<String> labels;
  final List<String> selectedLabels;
  final ValueChanged<List<String>> onFilterChanged;

  const FilterDropdown({super.key, 
    required this.labels,
    required this.selectedLabels,
    required this.onFilterChanged,
  });

  @override
  _FilterDropdownState createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  List<String> selectedLabels = [];

  @override
  void initState() {
    super.initState();
    selectedLabels = widget.selectedLabels;
  }

  void _onTap(String label) {
    setState(() {
      selectedLabels =
          List.from(selectedLabels); // Create a new modifiable list
      if (selectedLabels.contains(label)) {
        selectedLabels.remove(label);
      } else {
        selectedLabels.add(label);
      }
    });
    widget.onFilterChanged(selectedLabels);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.labels.length,
        itemBuilder: (context, index) {
          final label = widget.labels[index];
          return GestureDetector(
            onTap: () => _onTap(label),
            child: Chip(
              label: Text(label),
              backgroundColor: selectedLabels.contains(label)
                  ? Colors.blue
                  : Colors.grey[300],
            ),
          );
        },
      ),
    );
  }
}
