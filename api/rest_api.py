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
    init_db(engine, force=True)
    db = sqlalchemy.orm.sessionmaker()
    db.configure(bind=engine)
    db = db()
    app.db = db
except sqlalchemy.exc.OperationalError as e:
    print(f"Error connecting to MariaDB: {e}")
    sys.exit(1)

insert_from_csv(db, "inputData/recipe_details.csv", Recipe)


@app.get("/auth/status")
@marshal_with(UserSchema, code=200, description="Authenticated user")
@authenticated
def auth_status():
    return (g.user.asSchemeDict(), 200)


docs.register(auth_status)


@app.get("/")
def hello():
    return redirect("/swagger-ui")


# docs.register(hello)


@app.post("/recipes")
@use_kwargs(
    {"ingredients": fields.List(fields.Str(), required=True), "count": fields.Int()}
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
    recipes_as_dicts = [recipe.asSchemeDict() for recipe in db_recipes]
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
    return (recipe.asSchemeDict(), 200)


docs.register(recommend_recipe)
docs.register(recipe_by_id)


@app.get("/list")
@authenticated
def get_list():
    user = g.user
    if not user.shopping_list:
        new_list = ShoppingList(user)
        db.add(new_list)
        db.commit()
    shopping_list = db.query(ShoppingList).filter_by(id=user.shopping_list).first()
    return (shopping_list.asSchemeDict(), 200)


@app.post("/list/item")
@authenticated
def add_to_list():
    user = g.user
    if not user.shopping_list:
        new_list = ShoppingList(user)
        db.add(new_list)
        db.commit()
    shopping_list = db.query(ShoppingList).filter_by(id=user.shopping_list).first()
    ingredient = ListIngredient.fromRecipeIngredient(request.json.get("ingredient"))
    db.add(ingredient)
    shopping_list.addIngredient(ingredient)
    db.commit()
    shopping_list.update()
    return (shopping_list.asSchemeDict(), 200)


@app.delete("/list/item")
@authenticated
def remove_from_list():
    user = g.user
    if not user.shopping_list:
        new_list = ShoppingList(user)
        db.add(new_list)
        db.commit()
    shopping_list = db.query(ShoppingList).filter_by(id=user.shopping_list).first()
    ingredient = ListIngredient.fromRecipeIngredient(request.json.get("ingredient"))
    shopping_list.removeIngredient(ingredient)
    db.commit()
    return (shopping_list.asSchemeDict(), 200)


@app.delete("/list")
@authenticated
def clear_list():
    user = g.user
    if not user.shopping_list:
        new_list = ShoppingList(user)
        db.add(new_list)
        db.commit()
    shopping_list = db.query(ShoppingList).filter_by(id=user.shopping_list).first()
    shopping_list.clear()
    db.commit()
    return (shopping_list.asSchemeDict(), 200)


docs.register(get_list)
docs.register(add_to_list)
docs.register(remove_from_list)
docs.register(clear_list)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 3000))
    app.run(
        debug=bool(os.environ.get("DEBUG", True)),
        host="0.0.0.0",
        port=port,
        # ssl_context="adhoc",
    )
    print("Closing db connection...")
    db.close()
