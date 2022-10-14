import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
import pickle
import unidecode
import ast


# Getting the top-n recomendations ordered by the score
def get_recommendations(n, scores):
    # Loading in recipe dataset
    df_recipes = pd.read_csv('/Users/saini/Desktop/RecipeAI/inputData/recipe_details.csv')
    # Ordering the scores and filtering them to get the highest n scores
    top = sorted(range(len(scores)), key=lambda i: scores[i], reverse=True)[:n]
    # Creating a dataframe to load in the recommendations
    recommendation = pd.DataFrame(columns=['recipe', 'ingredients', 'score', 'url'])
    count = 0
    for i in top:
        recommendation.at[count, 'recipe'] = title_parser(df_recipes['recipe_name'][i])
        print(recommendation.at[count, 'recipe'])
        recommendation.at[count, 'ingredients'] = ingredient_parser_final(df_recipes['r_ingrids'][i])
        print(recommendation.at[count, 'ingredients'])
        recommendation.at[count, 'url'] = df_recipes['recipe_urls'][i]
        print(recommendation.at[count, 'url'])
        recommendation.at[count, 'score'] = "{:.3f}".format(float(scores[i]))
        print(recommendation.at[count, 'score'])
        count += 1
    return recommendation


# Neatening the ingredients that are being outputted
def ingredient_parser_final(ingredient):
    if isinstance(ingredient, list):
        ingredients = ingredient
    else:
        ingredients = ast.literal_eval(ingredient)

    ingredients = ','.join(ingredients)
    ingredients = unidecode.unidecode(ingredients)
    return ingredients


# Returning the title of the recipe
def title_parser(title):
    title = unidecode.unidecode(title)
    return title


def rec_system(ingredients, n=5):
    # The recommendation system is given a list of ingredients (param = ingredients)
    # Based on the cosine similarity it will return the top 5 recipes (number of recipes to give back, n=5)

    # Loading in the tdidf model and encodings
    with open('/Users/saini/Desktop/RecipeAI/inputData/tfidf_encodings.pkl', 'rb') as f:
        tfidf_encodings = pickle.load(f)

    with open('/Users/saini/Desktop/RecipeAI/models/tfidf.pkl', "rb") as f:
        tfidf = pickle.load(f)

    # This should parse the ingriedients with the use of the clean_parse_ingreds.py but it seems to be not needed here
    try:
        ingredients_parsed = ingredients
    except:
        ingredients_parsed = [ingredients]
    print(ingredients_parsed)

    # Using the pretrained tfidf model to encode the input ingredients
    ingredients_tfidf = tfidf.transform([ingredients_parsed])
    print(ingredients_tfidf)
    # Calculating the cosine similarity between the actual recipe ingreds and test ingreds
    cos_sim = map(lambda x: cosine_similarity(ingredients_tfidf, x), tfidf_encodings)
    scores = list(cos_sim)
    print(cos_sim)
    print(scores)
    # Getting the top n recommendations
    recommendations = get_recommendations(n, scores)
    return recommendations


if __name__ == "__main__":
    # Testing the system with these test ingreds
    test_ingredients = "chicken thigh, apple, onion, rice noodle"
    test_ingredients2 = "strawberry, hdh, icecream, donuts, chsmpion, flowers, a, salad, tomato, onion, salad, icecream, jam, cheese, chocolate"
    recs = rec_system(test_ingredients)
    print(recs.score)
