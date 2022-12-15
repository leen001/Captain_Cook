import 'package:captain_cook/states.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectedIngredients extends StatelessWidget {
  final bool dismissable;
  const SelectedIngredients({super.key, this.dismissable = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<AvailableIngredients>(
        builder: (context, availableIngredients, child) => Row(
            children: availableIngredients.selected
                .map((ingredient) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Chip(
                      label: Text(ingredient),
                      onDeleted: dismissable
                          ? () {
                              availableIngredients.deselect(ingredient);
                            }
                          : null,
                    )))
                .toList()));
  }
}
