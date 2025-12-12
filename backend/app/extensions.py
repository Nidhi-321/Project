from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
import redis
from flask import current_app

db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()

class RedisClient:
    def __init__(self):
        self._client = None
    def init_app(self, app):
        self._client = redis.from_url(app.config['REDIS_URL'])
    @property
    def client(self):
        return self._client

redis_client = RedisClient()
