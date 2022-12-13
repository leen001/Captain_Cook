import re
from unicodedata import *
from fractions import Fraction as F
import csv
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.engine.base import Engine
from sqlalchemy.orm.session import Session
from sqlalchemy.exc import IntegrityError
from schemas import (
    UserSchema,
    RecipeSchema,
    IngredientSchema,
    ShoppingListSchema,
    RatingSchema,
    validateSchema,
    AvailableIngredientSchema,
)

from schemas import UserSchema

from ingredient_parser import parse_ingredient


Base = declarative_base()


def init_db(engine: Engine, force: bool = False):
    if force:
        Base.metadata.drop_all(engine)
    print(f"Creating database tables for models: {Base.metadata.tables.keys()}")
    Base.metadata.create_all(engine, checkfirst=bool(not force))
    print("Database tables created")


def insert_from_csv(
    session: Session, csv_file: str, model: Base, overwrite: bool = False
):
    print(f"Inserting data from {csv_file} into {model.__tablename__}...")
    items = list()
    with open(csv_file, "r") as f:
        reader = csv.reader(f)
        reader.__next__()
        for row in reader:
            el = model(*row)
            items.append(el)
    existing = session.query(model).all()
    if overwrite or len(items) > len(existing):
        session.add_all(items)
        session.commit()
        print(f"Inserted {len(items)} items into {model.__tablename__}")
    else:
        print(
            f"Skipped inserting {len(items)} items into {model.__tablename__} because there are already {len(existing)} items in the database"
        )


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    google_uid = Column(String(50), unique=True)
    name = Column(String(50))
    mail = Column(String(80), unique=True)
    picture = Column(String(100))
    first_contact = Column(DateTime, default=datetime.utcnow)
    last_contact = Column(DateTime, default=datetime.utcnow)
    shopping_list = Column(ForeignKey("shopping_lists.id"))

    def __init__(self, google_uid, name=None, mail=None, picture=None):
        self.google_uid = google_uid
        self.name = name
        self.mail = mail
        self.picture = picture

    def get_by_gid(self, google_id, session: Session):
        return session.query(User).filter_by(google_uid=google_id).first() or None

    def login(self, session: Session):
        self.last_contact = datetime.utcnow()
        session.add(self)
        session.commit()
        return self

    def asSchemaDict(self):
        return UserSchema().dump(self)


class Rating(Base):
    __tablename__ = "ratings"
    id = Column(Integer, primary_key=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    rating = Column(Integer)
    comment = Column(String(500))

    def __init__(self, recipe_id, user_id, rating, comment=None):
        self.recipe_id = recipe_id
        self.user_id = user_id
        self.rating = rating
        self.comment = comment

    def asSchemaDict(self):
        return RatingSchema().dump(self)


class Recipe(Base):
    __tablename__ = "recipes"
    id = Column(Integer, primary_key=True)
    url = Column(String(200), unique=True)
    recipe = Column(String(100))
    prep_time = Column(String(50))
    cooking_time = Column(String(50))
    total_time = Column(String(50))
    recipe_servings = Column(Integer)
    recipe_yield = Column(String(50))
    ingredients = Column(String(1000))
    r_direction = Column(Text)
    r_nutrition_info = Column(String(500))
    ratings = relationship(lambda: Rating, uselist=True, cascade="all, delete-orphan")

    def __init__(
        self,
        url,
        recipe,
        prep_time,
        cooking_time,
        total_time,
        recipe_servings,
        recipe_yield,
        ingredients,
        r_direction,
        r_nutrition_info,
    ):
        self.url = url
        self.recipe = recipe
        self.prep_time = prep_time
        self.cooking_time = cooking_time
        self.total_time = total_time
        self.recipe_servings = recipe_servings if len(recipe_servings) > 0 else 0
        self.recipe_yield = recipe_yield
        self.ingredients = ingredients
        self.r_direction = r_direction
        self.r_nutrition_info = r_nutrition_info

    def asSchemaDict(self, include_ratings=True):
        recipe = RecipeSchema().dump(self)
        if include_ratings:
            recipe["ratings"] = [r.asSchemaDict() for r in self.ratings]
        return recipe

    def addRating(self, user_id, rating, comment=None):
        rating = Rating(self.id, user_id, rating, comment)
        self.ratings.append(rating)
        return rating


def replaceVulgarFractions(s: str):
    def f(s):
        return (
            F(s.translate({8260: 47, 8543: "1/"}))
            if s[1:]
            else F(numeric(s)).limit_denominator()
        )

    to_replace = re.findall(r"[\u2150-\u215E\u00BC-\u00BE]", s)
    for r in to_replace:
        s = s.replace(r, str(f(r)))
    return s


class ListIngredient(Base):
    __tablename__ = "list_ingredients"
    id = Column(Integer, primary_key=True)
    shopping_list_id = Column(Integer, ForeignKey("shopping_lists.id"))
    name = Column(String(200))
    quantity = Column(String(50))
    unit = Column(String(50))
    condition = Column(String(50))
    icon = Column(String(100))

    def __init__(
        self, name="surprise", quantity=0, unit=None, condition=None, icon=None
    ):
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.condition = condition
        self.icon = icon

    def fromRecipeIngredient(self, recipeIngredient: str):
        # safe_for_parse = replaceVulgarFractions(recipeIngredient)
        safe_for_parse = recipeIngredient
        parsed = parse_ingredient(safe_for_parse)
        self.name = parsed.get("name", "surprise")
        self.quantity = parsed.get("quantity", 0)
        self.unit = parsed.get("unit", None)
        self.condition = parsed.get("comment", None)
        return self

    def asSchemaDict(self):
        return IngredientSchema().dump(self)


class ShoppingList(Base):
    __tablename__ = "shopping_lists"
    id = Column(Integer, primary_key=True)
    user = relationship("User", uselist=False, cascade="all, delete-orphan")
    ingredients = relationship(
        lambda: ListIngredient, uselist=True, cascade="all, delete-orphan"
    )

    def __init__(self, user: User):
        self.user = user

    def asSchemaDict(self):
        shopping_list = ShoppingListSchema().dump(self)
        shopping_list["ingredients"] = [i.asSchemaDict() for i in self.ingredients]
        return shopping_list

    def addIngredient(self, ingredient: ListIngredient):
        self.ingredients.append(ingredient)

    def addRecipe(self, recipe: Recipe) -> list[ListIngredient]:
        ingredients = list()
        for i in recipe.ingredients[2:-2].split("', '"):
            ingredients.append(ListIngredient().fromRecipeIngredient(i))
            self.addIngredient(ingredients[-1])
        return ingredients

    def removeIngredient(self, ingredient: ListIngredient):
        self.ingredients.remove(ingredient)

    def clearIngredients(self):
        ingredients = self.ingredients
        for i in ingredients:
            self.removeIngredient(i)
        return ingredients


class AvailableIngredient(Base):
    __tablename__ = "available_ingredients"
    name = Column(String(200), primary_key=True)

    def __init__(self, name):
        self.name = name

    def asSchemaDict(self):
        return AvailableIngredientSchema().dump(self)


def init_ingredients(session: Session, clean=False):
    recipes = session.query(Recipe).all()
    ingredient_names = set()
    if clean:
        for ing in session.query(AvailableIngredient).all():
            session.delete(ing)
        session.commit()
        print(
            f"Deleted all ingredients (remaining: {len(session.query(AvailableIngredient).all())})"
        )
    else:
        ingredient_names = [i.name for i in session.query(AvailableIngredient).all()]
    for recipe in recipes:
        for ingredient in recipe.ingredients[2:-2].split("', '"):
            ing_name = ListIngredient().fromRecipeIngredient(ingredient).name.lower()
            ingredient_names.add(ing_name)
    ingredients = [AvailableIngredient(i) for i in ingredient_names]
    if len(ingredients) > 0:
        print(f"Adding {len(ingredients)} ingredients to database")
        for i in ingredients:
            session.add(i)
            try:
                session.commit()
            except IntegrityError as e:
                print(f"Error adding ingredient: {i.name}")
                session.rollback()
        print(
            f"Number of ingredients in database: {len(session.query(AvailableIngredient).all())}"
        )
    else:
        print("No new ingredients to add")
