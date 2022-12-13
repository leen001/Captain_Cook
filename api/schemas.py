import marshmallow as ma


class BasicError(ma.Schema):
    error = ma.fields.Str()


class AuthError(ma.Schema):
    token = ma.fields.Str()
    error = ma.fields.Str()


class BasicSuccess(ma.Schema):
    success = ma.fields.Str()


class RatingSchema(ma.Schema):
    id = ma.fields.Integer()
    recipe_id = ma.fields.Integer()
    user_id = ma.fields.Integer()
    rating = ma.fields.Integer(validate=lambda x: 0 <= x <= 5)
    comment = ma.fields.String(allow_none=True)


class RecipeSchema(ma.Schema):
    id = ma.fields.Int()
    recipe = ma.fields.String()
    prep_time = ma.fields.String()
    cooking_time = ma.fields.String()
    total_time = ma.fields.String()
    recipe_servings = ma.fields.Number()
    recipe_yield = ma.fields.String()
    ingredients = ma.fields.String()
    r_direction = ma.fields.String()
    r_nutrition_info = ma.fields.String()
    ratings = ma.fields.Nested(RatingSchema, many=True, allow_none=True)
    rating_score = ma.fields.Number(allow_none=True)


class RecipeRecommendationSchema(RecipeSchema):
    score = ma.fields.Int()


class UserSchema(ma.Schema):
    id = ma.fields.Integer()
    name = ma.fields.String(allow_none=True)
    mail = ma.fields.String()
    picture = ma.fields.String(allow_none=True)


class IngredientInputSchema(ma.Schema):
    name = ma.fields.String()
    quantity = ma.fields.String(allow_none=True)
    unit = ma.fields.String(allow_none=True)
    condition = ma.fields.String(allow_none=True)
    icon = ma.fields.String(allow_none=True)


class AvailableIngredientSchema(ma.Schema):
    name = ma.fields.String()


class IngredientSchema(IngredientInputSchema):
    id = ma.fields.Integer()


class ShoppingListSchema(ma.Schema):
    id = ma.fields.Integer()
    ingredients = ma.fields.Nested(
        IngredientSchema, many=True, allow_none=True)


def validateSchema(schema: ma.Schema, data: dict):
    assert len(schema().validate(
        data)) == 0, f"{schema.__name__} validation failed! ({', '.join(schema().validate(data))})"
