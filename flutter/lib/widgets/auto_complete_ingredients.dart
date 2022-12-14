import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api.dart';
import '../states.dart';

class AutoCompleteIngredients extends StatefulWidget {
  const AutoCompleteIngredients({super.key});

  @override
  State<AutoCompleteIngredients> createState() =>
      _AutoCompleteIngredientsState();
}

class _AutoCompleteIngredientsState extends State<AutoCompleteIngredients> {
  String _displayStringForOption(String option) => option;

  @override
  Widget build(BuildContext context) {
    AvailableIngredients ingredients =
        Provider.of<AvailableIngredients>(context);
    if (ingredients.isEmpty) {
      ingredients.loadFromApi(CCApi().getPossibleIngredients);
    }
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        } else {
          return ingredients.names.where((String option) {
            return option.contains(textEditingValue.text.toLowerCase());
          });
        }
        // if (AvailableIngredients.contains( option)) {
        //   return option.contains(textEditingValue.text.toLowerCase());
        // }
        // return AvailableIngredients.contains((String option) {
        //   return option.contains(textEditingValue.text.toLowerCase());
        // },);
      },
      onSelected: (String selection) {
        // Consumer<SelectedIng>(
        //   builder: (context, selectedIng, child) => selectedIng.add(selection),
        // );
        ingredients.select(selection);

        //Navigator.pop(context, selection);
        return;
      },
    );
  }

  void _returnToStart(String selectedIngredient) {
    //remove the text in input field
    //AvailableIngredients.remove(selectedIngredient);
  }

//   void _startRecipeOutput() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => RecipeList(_selectedIngredients)),
//     );
}
