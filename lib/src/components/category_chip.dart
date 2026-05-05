import 'package:flutter/material.dart';
import '../theme/design_system.dart';

typedef ChipTapCallback = void Function(bool selected);

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.activeColor = GatherColors.primary,
    this.inactiveColor = Colors.white,
  });

  final String label;
  final bool selected;
  final ChipTapCallback? onTap;
  final Widget? icon;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? activeColor : inactiveColor;
    final fg = selected ? Colors.white : GatherColors.textPrimary;

    return GestureDetector(
      onTap: () => onTap?.call(!selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? activeColor : const Color(0xFFE6E9F2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              IconTheme(
                data: IconThemeData(color: fg, size: 16),
                child: icon!,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
