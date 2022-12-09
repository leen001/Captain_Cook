import os
import sys
from flask import Flask, g, redirect, request, url_for
from flask_cors import CORS
import sqlalchemy
from webargs import fields
from marshmallow import Schema
from flask_apispec import use_kwargs, marshal_with, FlaskApiSpec
from middlewares import authenticated
from db import User, Recipe, ShoppingList, ListIngredient, init_db, insert_from_csv

from schemas import (
    BasicError,
    BasicSuccess,
    AuthError,
    RecipeSchema,
    RecipeRecommendationSchema,
    UserSchema,
    ShoppingListSchema,
    IngredientSchema,
    IngredientInputSchema,
)
import recommendation_system as rs


app = Flask(__name__)
app.app_context().push()
app.url_map.strict_slashes = False
app.secret_key = os.environ.get("SECRET_KEY") or os.urandom(24)
docs = FlaskApiSpec(app, document_options=False)
CORS(app)

try:
    engine = sqlalchemy.create_engine(
        f"mariadb+mariadbconnector://{os.environ.get('DB_USER', 'root')}:{os.environ.get('DB_PASSWORD', 'root')}@{os.environ.get('DB_HOST', 'localhost')}:{int(os.environ.get('DB_PORT', 3306))}/{os.environ.get('DB_DATABASE', 'cookbook')}"
    )
    init_db(engine, force=os.environ.get("DB_FORCE_RECREATE", False))
    db = sqlalchemy.orm.sessionmaker()
    db.configure(bind=engine)
    db = db()
    app.db = db
except sqlalchemy.exc.OperationalError as e:
    print(f"Error connecting to MariaDB: {e}")
    sys.exit(1)


@app.get("/auth/status")
@marshal_with(UserSchema, code=200, description="Authenticated user")
@authenticated
def auth_status():
    return (g.user.asSchemaDict(), 200)


docs.register(auth_status)


@app.get("/")
def hello():
    return redirect("/swagger-ui")


# docs.register(hello)


@app.post("/recipes")
@use_kwargs(
    {"ingredients": fields.List(
        fields.Str(), required=True), "count": fields.Int()}
)
@marshal_with(
    Schema.from_dict(
        {"recipes": fields.Nested(RecipeRecommendationSchema, many=True)},
        name="RecipeRecommendations",
    ),
    code=200,
)
@marshal_with(BasicError, code=400, description="Bad request")
def recommend_recipe(ingredients=list(), count=5):
    if len(ingredients) < 1:
        return ({"error": "Please provide at least one ingredient."}, 400)
    if count < 1:
        return ({"error": "Please provide a positive number for n."}, 400)
    db_recipes = db.query(Recipe).all()
    recipes_as_dicts = [recipe.asSchemaDict() for recipe in db_recipes]
    recipes = rs.rec_system(ingredients, recipes_as_dicts, n=count)

    return (
        {"recipes": recipes, "count": len(recipes)},
        200,
    )


@app.get("/recipes/<recipe_id>")
@marshal_with(RecipeSchema, code=200)
@marshal_with(BasicError, code=404, description="Recipe not found")
def recipe_by_id(recipe_id):
    recipe = db.query(Recipe).filter_by(id=recipe_id).first()
    if not recipe:
        return ({"error": "Recipe not found"}, 404)
    return (recipe.asSchemaDict(), 200)


docs.register(recommend_recipe)
docs.register(recipe_by_id)


def get_or_create_shopping_list(user):
    if not user.shopping_list:
        new_list = ShoppingList(user)
        db.add(new_list)
        db.commit()
    shopping_list = db.query(ShoppingList).filter_by(
        id=user.shopping_list).first()
    return shopping_list


@app.get("/list")
@marshal_with(ShoppingListSchema, code=200)
@authenticated
def get_list():
    shopping_list = get_or_create_shopping_list(g.user)
    return (shopping_list.asSchemaDict(), 200)


@app.post("/list/item")
@use_kwargs({"ingredient": fields.Nested(IngredientInputSchema)})
@marshal_with(ShoppingListSchema, code=200)
@authenticated
def add_to_list(ingredient=dict()):
    shopping_list = get_or_create_shopping_list(g.user)
    db_ingredient = ListIngredient(**ingredient)
    db.add(db_ingredient)
    shopping_list.addIngredient(db_ingredient)
    db.commit()
    return (shopping_list.asSchemaDict(), 200)


@app.post("/list/recipe")
@use_kwargs({"recipe_id": fields.Int()})
@marshal_with(ShoppingListSchema, code=200)
@authenticated
def add_recipe_to_list(recipe_id: int):
    shopping_list = get_or_create_shopping_list(g.user)
    recipe = db.query(Recipe).filter_by(
        id=recipe_id).first()
    if not recipe:
        return ({"error": "Recipe not found"}, 404)
    ingredients = shopping_list.addRecipe(recipe)
    for ingredient in ingredients:
        db.add(ingredient)
    db.commit()
    return (shopping_list.asSchemaDict(), 200)


@app.delete("/list/item")
@use_kwargs({"ingredient_id": fields.Int()})
@marshal_with(ShoppingListSchema, code=200)
@marshal_with(BasicError, code=404, description="Ingredient not found")
@authenticated
def remove_from_list(ingredient_id: int):
    shopping_list = get_or_create_shopping_list(g.user)
    ingredient = db.query(ListIngredient).filter_by(
        id=ingredient_id).first()
    if not ingredient or ingredient not in shopping_list.ingredients:
        return ({"error": "Ingredient not found"}, 404)
    shopping_list.removeIngredient(ingredient)
    db.delete(ingredient)
    db.commit()
    return (shopping_list.asSchemaDict(), 200)


@app.delete("/list")
@marshal_with(ShoppingListSchema, code=200)
@authenticated
def clear_list():
    shopping_list = get_or_create_shopping_list(g.user)
    ingredients = shopping_list.clearIngredients()
    for ingredient in ingredients:
        db.delete(ingredient)
    db.commit()
    return (shopping_list.asSchemaDict(), 200)


docs.register(get_list)
docs.register(add_to_list)
docs.register(add_recipe_to_list)
docs.register(remove_from_list)
docs.register(clear_list)

if __name__ == "__main__":
    insert_from_csv(db, "inputData/recipe_details.csv", Recipe)

    port = int(os.environ.get("PORT", 3000))
    if os.environ.get("DEBUG", False):
        app.run(debug=True, host="0.0.0.0", port=port)
    else:
        app.run(
            host="0.0.0.0",
            port=port,
            # ssl_context="adhoc",
        )
    print("Closing db connection...")
    db.close()
