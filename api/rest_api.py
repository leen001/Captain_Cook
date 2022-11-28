import os
import sys
from flask import Flask, g, redirect, request, url_for
import sqlalchemy
from webargs import fields
from marshmallow import Schema
from flask_apispec import use_kwargs, marshal_with, FlaskApiSpec
from middlewares import authenticated
from db import User, Recipe, init_db, insert_from_csv

from schemas import BasicError, BasicSuccess, AuthError, RecipeSchema, UserSchema
import recommendation_system


app = Flask(__name__)
app.app_context().push()
app.url_map.strict_slashes = False
app.secret_key = os.environ.get("SECRET_KEY") or os.urandom(24)
docs = FlaskApiSpec(app, document_options=False)

try:
    engine = sqlalchemy.create_engine(
        f"mariadb+mariadbconnector://{os.environ.get('DB_USER', 'root')}:{os.environ.get('DB_PASSWORD', 'root')}@{os.environ.get('DB_HOST', 'localhost')}:{int(os.environ.get('DB_PORT', 3306))}/{os.environ.get('DB_DATABASE', 'cookbook')}")
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
    {"ingredients": fields.List(
        fields.Str(), required=True), "count": fields.Int()}
)
@marshal_with(
    Schema.from_dict(
        {"recipes": fields.Nested(RecipeSchema, many=True)},
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
    app.run(
        debug=bool(os.environ.get("DEBUG", True)),
        host="0.0.0.0",
        port=port,
        # ssl_context="adhoc",
    )
    print("Closing db connection...")
    db.close()
