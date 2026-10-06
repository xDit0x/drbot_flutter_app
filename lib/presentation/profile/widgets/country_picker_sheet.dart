import 'package:flutter/material.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_learning/domain/entities/contact/country_phone.dart';

class CountryPickerSheet extends StatelessWidget {
  final CountryPhone selected;
  const CountryPickerSheet({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      shrinkWrap: true,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: Theme.of(context).colorScheme.surfaceContainer,
            boxShadow: List.filled(
              1,
              BoxShadow(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                offset: Offset.fromDirection(1, 1),
                spreadRadius: 1,
                blurRadius: 1.2,
                blurStyle: BlurStyle.outer,
              ),
            ),
          ),
          child: Text(
            'Seleccione el pais',
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        for (final c in CountryPhone.values)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              color: selected == c
                  ? AppColors.primary.withAlpha(60)
                  : Colors.transparent,
            ),
            child: ListTile(
              leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
              title: Row(
                children: [
                  Text(
                    c.dialCode,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(' - ${c.name}'),
                ],
              ),
              trailing: c == (selected) ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, c),
            ),
          ),
      ],
    );
  }
}
