from flask import Flask
from .config import Config
from .extensions import db, migrate, jwt, redis_client
from .routes.auth import auth_bp
from .routes.keys import keys_bp
from .routes.steg import steg_bp
import logging
from logging.handlers import RotatingFileHandler
import os

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    # extensions
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    redis_client.init_app(app)

    # blueprints
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(keys_bp, url_prefix='/api/keys')
    app.register_blueprint(steg_bp, url_prefix='/api/steg')

    # logging
    if not os.path.exists('logs'):
        os.mkdir('logs')
    handler = RotatingFileHandler('logs/stegcrypt.log', maxBytes=5*1024*1024, backupCount=5)
    handler.setLevel(logging.INFO)
    app.logger.addHandler(handler)
    app.logger.setLevel(logging.INFO)

    return app
