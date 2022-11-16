import os
from flask import Flask, jsonify, request

import recommendation_system

app = Flask(__name__)


@app.route("/", methods=["GET"])
def hello():
    return HELLO_HTML


HELLO_HTML = """
     <html><body>
         <h1>Welcome the API</h1>
         <p>Please add ingredients to the url to receive recipe recommendations. </br>
            You can do this by appending "/recipe?ingredients= Pasta Tomato ..." to the current url.
         <br>Click <a href="/recipe?ingredients=pasta tomato onion">here</a> for an example when using the ingredients: pasta, tomato and onion.
     </body></html>
     """


@app.route("/recipe", methods=["GET"])
def recommend_recipe():
    ingredients = request.args.get("ingredients")
    count = request.args.get("count", 5, type=int)
    recipe = recommendation_system.rec_system(ingredients, count)

    response = {}
    for i, row in recipe.iterrows():
        # recipe_name,prep_time,cooking_time,total_time,recipe_servings,recipe_yield,r_ingrids,r_direction,r_nutrition_info
        response[i] = {
            "recipe": str(row["recipe"]),
            "ingredients": str(row["ingredients"]),
            "prep_time": str(row["prep_time"]),
            "cooking_time": str(row["cooking_time"]),
            "total_time": str(row["total_time"]),
            "recipe_servings": str(row["recipe_servings"]),
            "recipe_yield": str(row["recipe_yield"]),
            "r_direction": str(row["r_direction"]),
            "r_nutrition_info": str(row["r_nutrition_info"]),
            "score": str(row["score"])
        }
    return jsonify(response)


if __name__ == "__main__":
    port = os.environ.get("PORT", 3000, type=int)
    app.run(debug=bool(os.environ.get("DEBUG", True)), host="0.0.0.0", port=port)

# http://127.0.0.1:5000/recipe?ingredients=pasta

# use ipconfig getifaddr en0 in terminal (ipconfig if you are on windows, ip a if on linux)
# to find intenal (LAN) IP address. Then on any devide on network you can use server.
