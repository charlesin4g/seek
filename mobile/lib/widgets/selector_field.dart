import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class SelectorField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final VoidCallback onTap;
  final int labelFlex;
  final int fieldFlex;

  const SelectorField({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    required this.onTap,
    this.labelFlex = 2,
    this.fieldFlex = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: labelFlex,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: fieldFlex,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryDarkBlue,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.primaryDarkBlue,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
