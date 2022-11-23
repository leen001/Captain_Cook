import csv
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.engine.base import Engine
from sqlalchemy.orm.session import Session

Base = declarative_base()


def init_db(engine: Engine, force: bool = False):
    if force:
        Base.metadata.drop_all(engine)
    print(
        f"Creating database tables for models: {Base.metadata.tables.keys()}")
    Base.metadata.create_all(engine, checkfirst=bool(not force))
    print("Database tables created")


def insert_from_csv(session: Session, csv_file: str, model: Base):
    print(f"Inserting data from {csv_file} into {model.__tablename__}...")
    with open(csv_file, "r") as f:
        reader = csv.reader(f)
        reader.__next__()
        total = 0
        for row in reader:
            el = model(*row)
            session.add(el)
            total += 1
    session.commit()
    print(f"Data inserted ({total} rows)")


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    google_uid = Column(String(50), unique=True)
    name = Column(String(50))
    mail = Column(String(80))
    picture = Column(String(50))
    first_login = Column(DateTime, default=datetime.utcnow)
    last_login = Column(DateTime, default=datetime.utcnow)

    def __init__(self, google_uid, name=None, mail=None, picture=None):
        self.google_uid = google_uid
        self.name = name
        self.mail = mail
        self.picture = picture


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

    def __init__(self, url, name=None, prep_time=None, cook_time=None, total_time=None, servings=None, r_yield=None, ingredients=None, instructions=None, nutrition=None):
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
