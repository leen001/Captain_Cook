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
  String shownInput = '';
  late TextEditingController textEditingController;

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
      },
      onSelected: (String selection) {
        // Consumer<SelectedIng>(
        //   builder: (context, selectedIng, child) => selectedIng.add(selection),
        // );
        ingredients.select(selection);
        textEditingController.text = "";

        //Navigator.pop(context, selection);
        // return _returnToStart(selection);
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        textEditingController = fieldTextEditingController;
        return Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 30.0),
          child: TextField(
            controller: fieldTextEditingController,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Ingredient',
              hintText: 'Enter an ingredient',
              // labelStyle: TextStyle(fontSize: 30),
            ),
            onSubmitted: (String value) {
              value = '';
              onFieldSubmitted();
            },
          ),
        );
      },
    );
  }

  // void _returnToStart(String selectedIngredient) {
  //   ingredients.text = '';
  //   //remove the text in input field
  //   //AvailableIngredients.remove(selectedIngredient);
  // }
  // void _returnToStart(String selectedIngredient) {
  //   textEditingController.text =
  //   //remove the text in input field
  //   //AvailableIngredients.remove(selectedIngredient);
  // }

//   void _startRecipeOutput() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => RecipeList(_selectedIngredients)),
//     );
}
