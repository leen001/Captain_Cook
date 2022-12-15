// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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
  final int id;
  final String cooking_time;
  final List ingredients;
  final String prep_time;
  final List r_direction;
  final List r_nutrition_info;
  final List<Rating> ratings;
  final double? rating_score;
  final String recipe;
  final double recipe_servings;
  final String recipe_yield;
  final int? score;
  final String total_time;
  //final int uid;

  Recipe(
    this.id,
    this.cooking_time,
    this.ingredients,
    this.prep_time,
    this.r_direction,
    this.r_nutrition_info,
    this.ratings,
    this.rating_score,
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

    List<Rating> ratings = <Rating>[];
    for (var rating in json['ratings']) {
      ratings.add(Rating.fromJson(rating));
    }

    return Recipe(
      json['id'],
      json['cooking_time'],
      ingredientsList,
      json['prep_time'],
      r_directionList,
      r_nutrition_infoList,
      ratings,
      json['rating_score'],
      json['recipe'],
      json['recipe_servings'],
      json['recipe_yield'],
      json['score'],
      json['total_time'],
    );
  }
}

class Ingredient {
  final String name;
  final String? icon;
  final int? id;

  const Ingredient({required this.name, this.icon, this.id});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      icon: json['icon'],
      id: json['id'],
    );
  }
}

class Rating {
  final int id;
  final int recipe_id;
  final int user_id;
  final int rating;
  final String? comment;

  Rating(this.id, this.recipe_id, this.user_id, this.rating, this.comment);

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      json['id'],
      json['recipe_id'],
      json['user_id'],
      json['rating'],
      json['comment'],
    );
  }
}

class CCApiConstants {
  static String baseUrl = (dotenv.env['API_BASE_URL']!.isNotEmpty)
      ? dotenv.env['API_BASE_URL']!
      : 'http://localhost:3000';
  static String users = '/users';
  static String recipes = '/recipes';
  static String ingredients = '/ingredients';
  static String list = '/list';
}

class CCApi {
  Future<List<Ingredient>> getPossibleIngredients() async {
    try {
      final response = await http.get(
          Uri.parse('${CCApiConstants.baseUrl}${CCApiConstants.ingredients}'));
      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        final List<Ingredient> ingredients =
            json.map((i) => Ingredient.fromJson(i)).toList();
        return ingredients;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception('Failed to load ingredients: $e');
    }
  }

  Future<List<Recipe>> getRecipes(List<String> ingredients,
      {int count = 5}) async {
    Map<String, String> headers = {'Content-type': 'application/json'};
    String body = jsonEncode({'ingredients': ingredients, 'count': count});
    try {
      final response = await http.post(
          Uri.parse('${CCApiConstants.baseUrl}${CCApiConstants.recipes}'),
          headers: headers,
          body: body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<Recipe> recipes = json['recipes']
            .map<Recipe>((i) => Recipe.fromJson(i))
            .toList(growable: false);
        return recipes;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception('Failed to load recipes: $e');
    }
  }

  Map<String, String> _buildAuthHeaders(Map<String, String>? authHeaders) {
    Map<String, String> headers = authHeaders ?? {};
    headers['Content-type'] = 'application/json';
    return headers;
  }

  List<Ingredient> _parseShoppingList(List<dynamic> json) {
    final List<Ingredient> ingredients =
        json.map((i) => Ingredient.fromJson(i)).toList();
    return ingredients;
  }

  Future<List<Ingredient>> getShoppingList(
      Future<Map<String, String>>? authHeaders) async {
    Map<String, String> headers = await authHeaders ?? {};
    headers['Content-type'] = 'application/json';
    try {
      final response = await http.get(
          Uri.parse('${CCApiConstants.baseUrl}${CCApiConstants.list}'),
          headers: _buildAuthHeaders(await authHeaders));
      if (response.statusCode == 200) {
        return _parseShoppingList(jsonDecode(response.body)['ingredients']);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception('Failed to load shopping list: $e');
    }
  }

  Future<List<Ingredient>> addIngredientToShoppingList(
      String ingredient, Future<Map<String, String>>? authHeaders) async {
    String body = jsonEncode({
      'ingredient': {'name': ingredient}
    });
    try {
      final response = await http.post(
          Uri.parse('${CCApiConstants.baseUrl}${CCApiConstants.list}/item'),
          headers: _buildAuthHeaders(await authHeaders),
          body: body);
      if (response.statusCode == 200) {
        return _parseShoppingList(jsonDecode(response.body)['ingredients']);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception('Failed to add ingredient to shopping list: $e');
    }
  }

  Future<List<Ingredient>> removeIngredientFromShoppingList(
      int ingredientId, Future<Map<String, String>>? authHeaders) async {
    String body = jsonEncode({
      'ingredient_id': ingredientId,
    });
    try {
      final response = await http.delete(
          Uri.parse('${CCApiConstants.baseUrl}${CCApiConstants.list}/item'),
          headers: _buildAuthHeaders(await authHeaders),
          body: body);
      if (response.statusCode == 200) {
        return _parseShoppingList(jsonDecode(response.body)['ingredients']);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception('Failed to remove ingredient from shopping list: $e');
    }
  }

  Future<Recipe> addRatingToRecipe(int recipeId, int rating,
      Future<Map<String, String>>? authHeaders) async {
    String body = jsonEncode({'rating': rating});
    try {
      final response = await http.post(
          Uri.parse(
              '${CCApiConstants.baseUrl}${CCApiConstants.recipes}/$recipeId/rating'),
          headers: _buildAuthHeaders(await authHeaders),
          body: body);
      if (response.statusCode == 200) {
        return Recipe.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        throw Exception('Invalid rating or already rated');
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception('Failed to add rating to recipe: $e');
    }
  }
}
