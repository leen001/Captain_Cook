import marshmallow as ma

class BasicError(ma.Schema):
    error = ma.fields.Str()

class RecipeSchema(ma.Schema):
    recipe = ma.fields.String()
    ingredients = ma.fields.String()
    r_direction = ma.fields.String()
    prep_time = ma.fields.String()
    cooking_time = ma.fields.String()
    total_time = ma.fields.String()
    r_nutrition_info = ma.fields.String()
    recipe_servings = ma.fields.Number()
    recipe_yield = ma.fields.String()
    score = ma.fields.String()


class UserSchema(ma.Schema):
    uid = ma.fields.Integer()
    name = ma.fields.String()
    mail = ma.fields.String()
    picture = ma.fields.String()
