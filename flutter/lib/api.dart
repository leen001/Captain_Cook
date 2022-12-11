import 'dart:convert';

class CatFact {
  final String fact;
  final int length;
  CatFact(this.fact, this.length);

  factory CatFact.fromJson(Map<String, dynamic> json) {
    return CatFact(json['fact'], json['length']);
  }
}

class RecipeTest {
  final List ingredients;
  RecipeTest(this.ingredients);

  factory RecipeTest.fromJson(Map<String, dynamic> json) {
    String ingredients = json['ingredients'];
    List<String> ingredientsList = ingredients.split(',');
    return RecipeTest(ingredientsList);
    //return RecipeTest(jsonDecode());
  }
}

class Recipe {
  final String cooking_time;
  final List ingredients;
  final String prep_time;
  final List r_direction;
  final String r_nutrition_info;
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
    return Recipe(
      json['cooking_time'],
      ingredientsList,
      json['prep_time'],
      r_directionList,
      json['r_nutrition_info'],
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
}

//provider consumer das extern 