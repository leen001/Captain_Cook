import json
import os
from pathlib import Path
import sys
from flask import Flask, redirect, request, url_for
import sqlalchemy
from webargs import fields
from marshmallow import Schema
from flask_apispec import use_kwargs, marshal_with, FlaskApiSpec
from flask_login import (
    LoginManager,
    login_user,
    logout_user,
    login_required,
    current_user,
)
from oauthlib.oauth2 import WebApplicationClient
from oauthlib.oauth2.rfc6749.errors import InvalidGrantError
import requests
from db import User, Recipe, init_db, insert_from_csv

from schemas import BasicError, BasicSuccess, RecipeSchema, UserSchema
import recommendation_system

GOOGLE_CLIENT_ID = os.environ.get("GOOGLE_CLIENT_ID", None)
GOOGLE_CLIENT_SECRET = os.environ.get("GOOGLE_CLIENT_SECRET", None)
GOOGLE_DISCOVERY_URL = "https://accounts.google.com/.well-known/openid-configuration"


def get_google_endpoint(endpoint: str):
    return requests.get(GOOGLE_DISCOVERY_URL).json()[endpoint]


app = Flask(__name__)
app.url_map.strict_slashes = False
app.secret_key = os.environ.get("SECRET_KEY") or os.urandom(24)
docs = FlaskApiSpec(app, document_options=False)

login_manager = LoginManager()
login_manager.init_app(app)


@login_manager.user_loader
def user_loader(gid):
    return User.get_by_gid(gid, db)


# @login_manager.request_loader
# def request_loader(request):
#     gid = request.form.get("google_uid")
#     if gid:
#         return User.get_by_gid(gid, db)
#     return None


@login_manager.unauthorized_handler
def unauthorized_handler():
    return redirect(url_for("login"))


oauth_client = WebApplicationClient(GOOGLE_CLIENT_ID)

try:
    # db = mariadb.connect(
    #     **{
    #         "host": os.environ.get("DB_HOST", "localhost"),
    #         "port": int(os.environ.get("DB_PORT", 3306)),
    #         "user": os.environ.get("DB_USER", "root"),
    #         "password": os.environ.get("DB_PASSWORD", "root"),
    #         "database": os.environ.get("DB_DATABASE", "cookbook"),
    #     }
    # )
    engine = sqlalchemy.create_engine(
        f"mariadb+mariadbconnector://{os.environ.get('DB_USER', 'root')}:{os.environ.get('DB_PASSWORD', 'root')}@{os.environ.get('DB_HOST', 'localhost')}:{int(os.environ.get('DB_PORT', 3306))}/{os.environ.get('DB_DATABASE', 'cookbook')}")
    init_db(engine, force=True)
    db = sqlalchemy.orm.sessionmaker()
    db.configure(bind=engine)
    db = db()
except sqlalchemy.exc.OperationalError as e:
    print(f"Error connecting to MariaDB Platform: {e}")
    sys.exit(1)

insert_from_csv(db, "inputData/recipe_details.csv", Recipe)

# Flask-Login helper to retrieve a user from our db


@app.get("/auth/login")
@use_kwargs({
    "no_redirect": fields.Bool(missing=False),
}, location="query")
@marshal_with(None, code=302, description="Redirect to Google login page")
@marshal_with(Schema.from_dict({"success": fields.Str(), "redirect_uri": fields.Str()}, name="RedirectResponse"), code=200, description="Redirect URI")
@marshal_with(BasicError, code=500)  # TODO: Add error handling
def login(no_redirect: bool = False):
    # Find out what URL to hit for Google login
    authorization_endpoint = get_google_endpoint("authorization_endpoint")

    # Use library to construct the request for Google login and provide
    # scopes that let you retrieve user's profile from Google
    request_uri = oauth_client.prepare_request_uri(
        authorization_endpoint,
        redirect_uri=request.base_url + "/callback",
        scope=["openid", "email", "profile"],
    )
    return redirect(request_uri, code=302) if not no_redirect else ({"success": True, "redirect_uri": request_uri}, 200)


@app.get("/auth/login/callback")
@marshal_with(
    Schema.from_dict({"auth_code": fields.Str(), "user": fields.Nested(
        UserSchema)}, name="LoginCallbackResponse"),
    code=200,
)
@marshal_with(BasicError, code=400, description="API error (e.g. mail not verified)")
@marshal_with(BasicError, code=500)  # TODO: Add error handling
def callback():
    # Get authorization code Google sent back to you
    auth_code = request.args.get("code")
    token_endpoint = get_google_endpoint("token_endpoint")

    # Prepare and send a request to get tokens! Yay tokens!
    token_url, headers, body = oauth_client.prepare_token_request(
        token_endpoint,
        authorization_response=request.url,
        redirect_url=request.base_url,
        code=auth_code,
    )
    token_response = requests.post(
        token_url,
        headers=headers,
        data=body,
        auth=(GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET),
    )

    try:
        oauth_client.parse_request_body_response(
            json.dumps(token_response.json()))
    except InvalidGrantError:
        return ({"error": "Invalid auth code"}, 400)

    uri, headers, body = oauth_client.add_token(
        get_google_endpoint("userinfo_endpoint"))
    userinfo_response = requests.get(uri, headers=headers, data=body).json()
    if not userinfo_response.get("email_verified"):
        return ({"error": "User email not available or not verified"}, 400)
    unique_id = userinfo_response["sub"]
    users_email = userinfo_response["email"]
    picture = userinfo_response["picture"]
    users_name = userinfo_response["given_name"]

    # Create a user in our db with the information provided
    user = User(google_uid=unique_id, name=users_name,
                mail=users_email, picture=picture)
    user.login(db)
    login_user(user)
    return ({"auth_code": auth_code, "user":
             {"uid": unique_id, "name": users_name,
              "mail": users_email, "picture": picture}},
            200,
            )


@app.get("/auth/status")
@marshal_with(UserSchema, code=200)
@marshal_with(BasicError, code=401, description="User not logged in")
def status():
    if current_user.is_authenticated:
        return current_user, 200
    return ({"error": "User not logged in"}, 401)


@app.get("/auth/logout")
@marshal_with(BasicSuccess, code=200)
@marshal_with(BasicError, code=400)
def logout():
    if current_user.is_authenticated:
        logout_user()
        return ({"success": True}, 200)
    return ({"error": "Not logged in"}, 400)


docs.register(login)
docs.register(callback)
docs.register(status)
docs.register(logout)


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
