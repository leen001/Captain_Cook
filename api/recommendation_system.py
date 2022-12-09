from numpy import double
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
import pickle
import unidecode
import ast
import os

from schemas import RecipeSchema

fileDir = os.path.dirname(os.path.realpath("__file__"))
# filename = os.path.join(fileDir, 'inputData/recipe_details.csv')
weights_for_recipes = os.path.join(fileDir, "inputData/tfidf_encodings.pkl")
ingredient_encodings = os.path.join(fileDir, "models/tfidf.pkl")

# Getting the top-n recomendations ordered by the score


def get_recommendations(n, scores, recipes_as_dict):
    # build df from list of recipes (dicts)
    df_recipes = pd.DataFrame.from_dict(recipes_as_dict)
    # map scores to recipes in df
    df_recipes["score"] = [int(double(s[0][0]) * 100) for s in scores]
    # sort by score and return top n
    top = df_recipes.sort_values(by="score", ascending=False).head(n)
    # return top recipes as dicts
    recipes = top.to_dict("records")
    for recipe in recipes:
        assert (
            len(RecipeSchema().validate(recipe)) == 0
        ), "Invalid recipe schema: " + ", ".join(RecipeSchema().validate(recipe))
    return recipes


# Neatening the ingredients that are being outputted
def ingredient_parser_final(ingredient):
    if isinstance(ingredient, list):
        ingredients = ingredient
    else:
        ingredients = ast.literal_eval(ingredient)

    ingredients = ",".join(ingredients)
    ingredients = unidecode.unidecode(ingredients)
    return ingredients


# Returning the title of the recipe
def title_parser(title):
    title = unidecode.unidecode(title)
    return title


def rec_system(ingredients: list, recipes_as_dict: list, n=5):
    # The recommendation system is given a list of ingredients (param = ingredients)
    # Based on the cosine similarity it will return the top 5 recipes (number of recipes to give back, n=5)

    # Loading in the tdidf model and encodings
    with open(weights_for_recipes, "rb") as f:
        weights = pickle.load(f)

    with open(ingredient_encodings, "rb") as f:
        tfidf = pickle.load(f)

    # Using the pretrained tfidf model to encode the input ingredients
    ingredients_encoded = tfidf.transform([",".join(ingredients)])
    # Calculating the cosine similarity between the actual recipe ingreds and test ingreds
    cos_sim = map(lambda x: cosine_similarity(ingredients_encoded, x), weights)
    scores = list(cos_sim)
    # Getting the top n recommendations
    recommendations = get_recommendations(n, scores, recipes_as_dict)
    return recommendations


if __name__ == "__main__":
    # Testing the system with these test ingreds
    test_ingredients = "chicken thigh, apple, onion, rice noodle"
    test_ingredients2 = "strawberry, hdh, icecream, donuts, chsmpion, flowers, a, salad, tomato, onion, salad, icecream, jam, cheese, chocolate"
    recs = rec_system(test_ingredients)
    print(recs.score)
