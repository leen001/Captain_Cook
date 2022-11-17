import marshmallow as ma


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
