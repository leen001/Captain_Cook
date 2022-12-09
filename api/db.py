import csv
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.engine.base import Engine
from sqlalchemy.orm.session import Session
from schemas import UserSchema, RecipeSchema

from schemas import UserSchema

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
    total = 0
    with open(csv_file, "r") as f:
        reader = csv.reader(f)
        reader.__next__()
        for row in reader:
            el = model(*row)
            session.add(el)
            total += 1
    if total > 0 and (overwrite or session.query(model).count() < total):
        session.commit()
        print(f"Data inserted ({total} rows)")
    print(f"Data already inserted ({total} rows)")


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

    def asSchemeDict(self):
        d = {
            "uid": self.id,
            "name": self.name,
            "mail": self.mail,
            "picture": self.picture,
        }
        assert len(UserSchema().validate(d)) == 0, "UserSchema validation failed!"
        return d


class Recipe(Base):
    __tablename__ = "recipes"
    id = Column(Integer, primary_key=True)
    url = Column(String(200), unique=True)
    name = Column(String(100))
    prep_time = Column(String(50))
    cook_time = Column(String(50))
    total_time = Column(String(50))
    servings = Column(Integer)
    r_yield = Column(String(50))
    ingredients = Column(String(1000))
    instructions = Column(Text)
    nutrition = Column(String(500))

    def __init__(
        self,
        url,
        name=None,
        prep_time=None,
        cook_time=None,
        total_time=None,
        servings=None,
        r_yield=None,
        ingredients=None,
        instructions=None,
        nutrition=None,
    ):
        self.url = url
        self.name = name
        self.prep_time = prep_time
        self.cook_time = cook_time
        self.total_time = total_time
        # print(f"servings: {servings}", int(servings), type(int(servings)))
        self.servings = servings if len(servings) > 0 else 0
        self.r_yield = r_yield
        self.ingredients = ingredients
        self.instructions = instructions
        self.nutrition = nutrition

    def asSchemeDict(self):
        d = {
            "uid": self.id,
            "recipe": self.name,
            "ingredients": self.ingredients,
            "r_direction": self.instructions,
            "prep_time": self.prep_time,
            "cooking_time": self.cook_time,
            "total_time": self.total_time,
            "r_nutrition_info": self.nutrition,
            "recipe_servings": self.servings,
            "recipe_yield": self.r_yield,
        }
        assert (
            len(RecipeSchema().validate(d)) == 0
        ), "RecipeSchema validation failed! " + ", ".join(RecipeSchema().validate(d))
        return d


class ListIngredient(Base):
    __tablename__ = "list_ingredients"
    id = Column(Integer, primary_key=True)
    shopping_list_id = Column(Integer, ForeignKey("shopping_lists.id"))
    name = Column(String(100))
    quantity = Column(String(50))
    condition = Column(String(50))
    icon = Column(String(100))

    def __init__(self, name, quantity="1", condition=None, icon=None):
        self.name = name
        self.quantity = quantity
        self.condition = condition
        self.icon = icon

    def fromRecipeIngredient(self, recipeIngredient):
        parts = recipeIngredient.name.split(" ")
        self.name = " ".join(parts[1:])
        self.quantity = parts[0]
        # self.condition = parts[1] # TODO: parse condition

    def asSchemeDict(self):
        d = {
            "id": self.id,
            "name": self.name,
            "quantity": self.quantity,
            "condition": self.condition,
            "icon": self.icon,
        }
        # assert len(ListIngredientSchema().validate(
        #     d)) == 0, "ListIngredientSchema validation failed!"
        return d


class ShoppingList(Base):
    __tablename__ = "shopping_lists"
    id = Column(Integer, primary_key=True)
    user = relationship("User", uselist=False, cascade="all, delete-orphan")
    ingredients = relationship(lambda: ListIngredient, uselist=True)

    def __init__(self, user: User):
        self.user = user

    def asSchemeDict(self):
        d = {
            "id": self.id,
            "ingredients": [i.asSchemeDict() for i in self.ingredients],
        }
        # assert len(ShoppingListSchema().validate(
        #     d)) == 0, "ShoppingListSchema validation failed!"
        return d

    def addIngredient(self, ingredient: ListIngredient):
        self.ingredients.append(ingredient)

    def removeIngredient(self, ingredient: ListIngredient):
        self.ingredients.remove(ingredient)
