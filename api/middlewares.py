from functools import wraps
from flask import current_app, g, request, redirect, url_for
from flask_apispec import marshal_with, use_kwargs
import requests
from webargs import fields
from db import User
from sqlalchemy.orm.session import Session

from schemas import AuthError

GOOGLE_VALIDATION_URL = "https://www.googleapis.com/oauth2/v3/tokeninfo?access_token={}"


def validate_google_token(token):
    resp = requests.get(GOOGLE_VALIDATION_URL.format(token))
    return resp.status_code == 200, resp.json()


def authenticated(f):
    '''Decorator to check if user is authenticated using the Authorization header (Bearer token) for validation with Google (Authentication is done in the frontend)'''
    @wraps(f)
    @use_kwargs({
        'Authorization': fields.Str(required=True),
    }, location='headers')
    @marshal_with(AuthError, code=401, description="Authentication token is missing or invalid")
    def decorated_function(*args, **kwargs):
        token = request.headers.get('Authorization').split(
            ' ')[1] if request.headers.get('Authorization') and request.headers.get('Authorization').startswith('Bearer ') else None
        if not token or len(token) < 1:
            return ({"error": "Missing or malformed Authorization header", "token": token}, 401)
        tokenValid, googleUser = validate_google_token(token)
        if not tokenValid:
            return ({"error": "Invalid token", "token": token}, 401)
        dbUser = current_app.db.query(User).filter_by(
            google_uid=googleUser['sub']).first()
        if not dbUser:
            dbUser = User(
                google_uid=googleUser['sub'], mail=googleUser['email'])
            current_app.db.add(dbUser)
        dbUser.login(current_app.db)
        g.user = dbUser
        return f(*args, **dict((k, v) for k, v in kwargs.items() if k != 'Authorization'))
    return decorated_function
