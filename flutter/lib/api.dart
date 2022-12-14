import 'dart:convert';

class Recipes {
  final List ingredients;
  Recipes(this.ingredients);

  factory Recipes.fromJson(Map<String, dynamic> json) {
    String ingredients = json['ingredients'];
    List<String> ingredientsList = ingredients.split(',');
    return Recipes(ingredientsList);
  }
}

class Recipe {
  final String cooking_time;
  final List ingredients;
  final String prep_time;
  final List r_direction;
  final List r_nutrition_info;
  final String recipe;
  final double recipe_servings;
  final String recipe_yield;
  final int score;
  final String total_time;
  //final int uid;

  Recipe(
    this.cooking_time,
    this.ingredients,
    this.prep_time,
    this.r_direction,
    this.r_nutrition_info,
    this.recipe,
    this.recipe_servings,
    this.recipe_yield,
    this.score,
    this.total_time,
    //this.uid
  );

  factory Recipe.fromJson(Map<String, dynamic> json) {
    String ingredients = json['ingredients'];
    List<String> ingredientsList = ingredients.split('\', \'');
    ingredientsList[0] = ingredientsList[0].substring(2);
    ingredientsList[ingredientsList.length - 1] =
        ingredientsList[ingredientsList.length - 1].substring(
            0, ingredientsList[ingredientsList.length - 1].length - 2);
    String r_direction = json['r_direction'];
    List<String> r_directionList = r_direction.split('\', \'');
    r_directionList[0] = r_directionList[0].substring(2);
    r_directionList[r_directionList.length - 1] =
        r_directionList[r_directionList.length - 1].substring(
            0, r_directionList[r_directionList.length - 1].length - 2);
    String r_nutrition_info = json['r_nutrition_info'];
    List<String> r_nutrition_infoList = r_nutrition_info.split(';');
    r_nutrition_infoList[0] = r_nutrition_infoList[0].substring(2);
    r_nutrition_infoList[r_nutrition_infoList.length - 1] =
        r_nutrition_infoList[r_nutrition_infoList.length - 1].substring(0,
            r_nutrition_infoList[r_nutrition_infoList.length - 1].length - 2);

    return Recipe(
      json['cooking_time'],
      ingredientsList,
      json['prep_time'],
      r_directionList,
      r_nutrition_infoList,
      json['recipe'],
      json['recipe_servings'],
      json['recipe_yield'],
      json['score'],
      json['total_time'],
      //json['uid'],
    );
  }
}

class ApiConstants {
  static String baseUrl = 'http://localhost:3000/';
  static String usersEndpoint = '/users';
  static String recipesEndpoint = '/recipes';
  static String ingredientsEndpoint = '/ingredients';
}

class Ingredient {
  final String name;
  final String? icon;

  const Ingredient({required this.name, this.icon});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      icon: json['icon'],
    );
  }
}
