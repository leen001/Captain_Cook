import os
from flask import Flask, redirect
from webargs import fields
from flask_apispec import use_kwargs, marshal_with, FlaskApiSpec

import recommendation_system

app = Flask(__name__)
docs = FlaskApiSpec(app, document_options=False)


@app.get("/")
def hello():
    return redirect("/swagger-ui")


# docs.register(hello)


@app.post("/recipes")
@use_kwargs(
    {"ingredients": fields.List(fields.Str(), required=True), "count": fields.Int()}
)
# @marshal_with(
#     {
#         "recipes": fields.Nested(
#             {
#                 "recipe": fields.Str(),
#                 "ingredients": fields.Str(),
#                 "r_direction": fields.Str(),
#                 "prep_time": fields.Str(),
#                 "cooking_time": fields.Str(),
#                 "total_time": fields.Str(),
#                 "r_nutrition_info": fields.Str(),
#                 "recipe_servings": fields.Number(),
#                 "recipe_yield": fields.Str(),
#                 "score": fields.Str(),
#             },
#             many=True,
#         )
#     }
# )
def recommend_recipe(ingredients=list(), count=5):
    if len(ingredients) < 1:
        return ({"error": "Please provide at least one ingredient."}, 400)
    if count < 1:
        return ({"error": "Please provide a positive number for n."}, 400)
    recipes = recommendation_system.rec_system(", ".join(ingredients), count)

    return (
        {
            "recipes": [dict(row) for _, row in recipes.iterrows()],
            "count": recipes.shape[0],
        },
        200,
    )


docs.register(recommend_recipe)


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 3000))
    app.run(debug=bool(os.environ.get("DEBUG", True)), host="0.0.0.0", port=port)
