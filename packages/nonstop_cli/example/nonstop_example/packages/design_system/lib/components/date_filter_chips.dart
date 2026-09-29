import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

enum DateFilterType {
  week,
  month;

  String get displayName {
    switch (this) {
      case DateFilterType.week:
        return strings.common.week;
      case DateFilterType.month:
        return strings.common.month;
    }
  }
}

class DateFilterChips extends StatelessWidget {
  final DateFilterType selectedFilter;
  final ValueChanged<DateFilterType> onFilterChanged;

  const DateFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: DateFilterType.values.map((filter) {
        final isSelected = filter == selectedFilter;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FilterChip(
            label: Text(filter.displayName),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                onFilterChanged(filter);
              }
            },
            backgroundColor: colorScheme.surface,
            selectedColor: colorScheme.primary,
            checkmarkColor: colorScheme.onPrimary,
            labelStyle: TextStyle(
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.5),
                width: isSelected ? 1.5 : 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
